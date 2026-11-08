#!/usr/bin/env python3
"""Automate simulator notification delivery, localization and warm/cold tap navigation.

Requires Xcode and Maestro. Builds DebugLocalhost (or accepts an existing App.app),
creates an isolated simulator, then deletes only that simulator when finished.
Uses the local backend and existing manager login. Never resets the database or
substitutes in-app dependencies. Push injection does not call APNs/FCM services.
"""

import argparse
from datetime import datetime, timezone
import os
import json
from pathlib import Path
import plistlib
import re
import subprocess
import sys
import time
import uuid
from urllib.error import HTTPError, URLError
from urllib.request import Request, urlopen


IOS = Path(__file__).resolve().parents[1]
BUNDLE_ID = "dk.nicolaidam.letsgrow"
FLOW = IOS / ".maestro/notifications/feedback-received.yaml"
PREPARE = FLOW.parent / "support/prepare.yaml"
FIXTURE = IOS / "Modules/Tests/InsightsTests/Fixtures/feedback-received.apns"
BACKEND_URL = "http://localhost:8080"
HEALTH_URL = "http://localhost:8090/actuator/health"


def command(*arguments, timeout=120):
    return subprocess.check_output(arguments, text=True, stderr=subprocess.STDOUT, timeout=timeout).strip()


def failure_message(error):
    details = getattr(error, "output", None)
    return f"{error}\n{details.strip()}" if details else str(error)


def simctl(*arguments, timeout=120):
    return command("xcrun", "simctl", *arguments, timeout=timeout)


def create_simulator():
    runtimes = json.loads(simctl("list", "runtimes", "--json"))["runtimes"]
    eligible = [runtime for runtime in runtimes if runtime.get("isAvailable")
                and ".iOS-" in runtime["identifier"] and int(runtime["version"].split(".")[0]) >= 26]
    # Prefer the stable iOS 26 family where installed; preview runtimes may not
    # yet be supported by the installed Maestro XCTest driver.
    stable = [runtime for runtime in eligible if runtime["version"].startswith("26.")]
    if not eligible:
        raise RuntimeError("Install an iOS 26+ simulator runtime in Xcode")
    runtime = max(stable or eligible, key=lambda item: tuple(map(int, item["version"].split("."))))
    device_type = next(device for device in runtime["supportedDeviceTypes"] if device["productFamily"] == "iPhone")
    return simctl("create", f"LetsGrow Notifications {uuid.uuid4().hex[:8]}", device_type["identifier"], runtime["identifier"])


def build_app(device, output):
    derived_data = IOS / ".build/notification-derived-data"
    output.mkdir(parents=True, exist_ok=True)
    print("Building Feedback Localhost…", flush=True)
    with (output / "build.log").open("w") as log:
        subprocess.run([
            "xcodebuild", "build", "-project", str(IOS / "Feedback.xcodeproj"),
            "-scheme", "Feedback Localhost", "-configuration", "DebugLocalhost",
            "-destination", f"platform=iOS Simulator,id={device}",
            "-derivedDataPath", str(derived_data), "-skipMacroValidation", "CODE_SIGNING_ALLOWED=NO",
        ], stdout=log, stderr=subprocess.STDOUT, check=True, timeout=900)
    return derived_data / "Build/Products/DebugLocalhost-iphonesimulator/App.app"


def maestro(device, flow, output, **variables):
    variables["ARTIFACTS"] = str(output.resolve())
    if "SESSION_TITLE" in variables:
        title = variables["SESSION_TITLE"]
        # This runner launches with English preferences. Keep an independent
        # expectation so incorrect shipping translations cannot validate themselves.
        body = f"New feedback for ‘{title}’ · Responses: {variables['FEEDBACK_COUNT']}"
        variables["SESSION_TITLE_REGEX"] = re.escape(title)
        variables["NOTIFICATION_BODY_REGEX"] = "(?s).*" + re.escape(body) + ".*"
    arguments = ["maestro", "--device", device, "test", "--test-output-dir", str(output)]
    for key, value in variables.items():
        arguments.extend(["-e", f"{key}={value}"])
    arguments.append(str(flow))
    output.mkdir(parents=True, exist_ok=True)
    with (output / "console.log").open("w") as log:
        subprocess.run(arguments, stdout=log, stderr=subprocess.STDOUT, check=True, timeout=180)


def backend_request(method, path, token=None, payload=None):
    """Only talk to the fixed local API; never print response bodies or tokens."""
    headers = {"Accept": "application/json"}
    if token:
        headers["Authorization"] = f"Bearer {token}"
    data = None
    if payload is not None:
        headers["Content-Type"] = "application/json"
        data = json.dumps(payload).encode()
    request = Request(BACKEND_URL + path, data=data, headers=headers, method=method)
    try:
        with urlopen(request, timeout=30) as response:
            body = response.read()
            return json.loads(body) if body else None
    except HTTPError as error:
        raise RuntimeError(f"Local backend {method} {path} returned HTTP {error.code}; "
                           "check test-admin configuration and the manager fixture") from None
    except URLError:
        raise RuntimeError("Local backend is unavailable at http://localhost:8080") from None


def prepare_backend(skip_start=False, seed_manager=False):
    if not skip_start:
        subprocess.run([str(IOS.parent / "scripts/ios-backend"), "localhost"], check=True)
    try:
        with urlopen(HEALTH_URL, timeout=5) as response:
            if json.load(response).get("status") != "UP":
                raise RuntimeError("Local backend health is not UP")
    except (URLError, ValueError):
        raise RuntimeError("Local backend health failed at http://localhost:8090/actuator/health") from None
    if seed_manager:
        # Explicit opt-in replaces only the standard sample manager fixture.
        # No /admin/reset and no Compose volume deletion.
        backend_request("POST", "/admin/seed-manager-with-data")
    login = backend_request("POST", "/admin/login", payload={"id": "mock-manager-with-data"})
    token = login["session"]["accessToken"]
    bootstrap = backend_request("GET", "/bootstrap", token=token)
    if bootstrap.get("managerData") is None:
        raise RuntimeError("Sample manager is not prepared; rerun with --seed-manager")
    return token


def create_session(token, title):
    activity = backend_request("POST", "/activity", token=token, payload={
        "title": title, "questions": [{"questionText": "Was the meeting useful?", "feedbackType": "ZeroToTen"}],
        "runMode": "MANUAL", "invitedEmails": [], "sendEmails": False,
    })
    activity_id = str(uuid.UUID(activity["id"]))
    try:
        event = backend_request("POST", "/event", token=token, payload={
            "activityId": activity_id, "date": datetime.now(timezone.utc).isoformat(), "durationInMinutes": 30,
        })
        event_id = str(uuid.UUID(event["id"]))
        bootstrap = backend_request("GET", "/bootstrap", token=token)
        activities = bootstrap.get("managerData", {}).get("activities", [])
        if not any(item["id"] == activity_id and any(session["id"] == event_id for session in item["events"])
                   for item in activities):
            raise RuntimeError("Created session is missing from the real backend bootstrap")
        return activity_id, event_id
    except Exception:
        backend_request("DELETE", f"/activity/{activity_id}", token=token)
        raise


def launch_manager(device):
    environment = dict(os.environ, SIMCTL_CHILD_LETSGROW_LOCAL_TEST_ACCOUNT="manager")
    # Existing LocalTestAccountLaunch obtains Firebase credentials from the local
    # backend. No tokens are passed in CLI arguments or written to artifacts.
    subprocess.run(["xcrun", "simctl", "launch", "--terminate-running-process", device, BUNDLE_ID,
                    "-AppleLanguages", "(en)", "-AppleLocale", "en_US"],
                   env=environment, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, check=True, timeout=60)


def install_app(device, app):
    for attempt in range(3):
        try:
            simctl("install", device, str(app.resolve()))
            return
        except subprocess.CalledProcessError as error:
            # A freshly booted simulator can finish bootstatus before its
            # installation service is ready to create an installation promise.
            details = error.output or ""
            transient = "IXErrorDomain" in details and any(message in details for message in (
                "Failed to locate promise", "Failed to create promise",
            ))
            if not transient or attempt == 2:
                raise
            print("Simulator installation service is starting; retrying…", flush=True)
            time.sleep(2)


def run(args):
    # Check the actual shipped resources, including Danish fallback, before any
    # delivery assertions. Never patch a built app or substitute literal alerts.
    print(command(sys.executable, str(IOS / "scripts/validate-localization.py"),
                  "--app-bundle", str(args.app.resolve())), flush=True)
    with (args.app / "Info.plist").open("rb") as stream:
        info = plistlib.load(stream)
    if info.get("CFBundleIdentifier") != BUNDLE_ID:
        raise ValueError(f"Expected the Localhost app ({BUNDLE_ID})")
    devices = json.loads(simctl("list", "devices", "available", "--json"))["devices"]
    selected = next((device for group in devices.values() for device in group if device["udid"] == args.device), None)
    if not selected:
        raise ValueError("--device must identify an available iOS simulator")
    if selected["state"] != "Booted":
        simctl("boot", args.device)
        simctl("bootstatus", args.device, "-b", timeout=300)
    install_app(args.device, args.app)
    args.output.mkdir(parents=True, exist_ok=True)
    payload_template = json.loads(FIXTURE.read_text())
    results = []
    token = prepare_backend(args.skip_backend_start, args.seed_manager)
    try:
        for state in args.states:
            for count in args.counts:
                name = f"{state}-{count}"
                output = args.output / name
                run_id = str(uuid.uuid4())
                title = f"Weekly 100% møde {run_id[:8]}"
                print(f"Running {name}…", flush=True)
                activity_id = None
                try:
                    activity_id, event_id = create_session(token, title)
                    launch_manager(args.device)
                    maestro(args.device, PREPARE, output / "prepare", APP_STATE=state)
                    if state == "terminated":
                        simctl("terminate", args.device, BUNDLE_ID)
                    payload = json.loads(json.dumps(payload_template))
                    payload["eventId"] = event_id
                    payload["aps"]["alert"]["loc-args"] = [str(count), title]
                    output.mkdir(parents=True, exist_ok=True)
                    payload_path = output / "notification.apns"
                    payload_path.write_text(json.dumps(payload, ensure_ascii=False))
                    simctl("push", args.device, BUNDLE_ID, str(payload_path))
                    maestro(args.device, FLOW, output / "verify", SESSION_TITLE=title, FEEDBACK_COUNT=str(count))
                    results.append({"case": name, "passed": True})
                    print(f"PASS {name}", flush=True)
                except (subprocess.SubprocessError, RuntimeError, OSError) as error:
                    results.append({"case": name, "passed": False, "error": failure_message(error)})
                    print(f"FAIL {name} — see {output}", flush=True)
                finally:
                    if activity_id:
                        try:
                            backend_request("DELETE", f"/activity/{activity_id}", token=token)
                        except (RuntimeError, OSError) as error:
                            results.append({"case": name + "-cleanup", "passed": False, "error": str(error)})
    finally:
        try:
            simctl("terminate", args.device, BUNDLE_ID)
        except subprocess.SubprocessError:
            pass
        (args.output / "results.json").write_text(json.dumps(results, indent=2))
    return 0 if results and all(case["passed"] for case in results) else 1


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--app", type=Path, help="Use an existing DebugLocalhost App.app instead of building")
    parser.add_argument("--device", help="Reuse a simulator UUID instead of creating an isolated simulator")
    parser.add_argument("--counts", nargs="+", type=int, default=[99], help="Counts to check in each app state")
    parser.add_argument("--states", nargs="+", choices=["foreground", "background", "terminated"],
                        default=["foreground", "background", "terminated"], help="Delivery states to check")
    parser.add_argument("--skip-backend-start", action="store_true", help="Reuse the running local backend after checking health")
    parser.add_argument("--seed-manager", action="store_true", help="Replace only the standard mock-manager-with-data fixture before login")
    parser.add_argument("--output", type=Path, default=IOS / ".build/notification-tests")
    args = parser.parse_args()
    args.output = args.output.resolve()
    if any(count < 0 for count in args.counts):
        parser.error("counts must be nonnegative")
    created_device = None
    try:
        if not args.device:
            created_device = create_simulator()
            args.device = created_device
            print(f"Created isolated simulator {created_device}", flush=True)
        if not args.app:
            args.app = build_app(args.device, args.output)
        return run(args)
    except KeyboardInterrupt:
        return 130
    except (KeyError, ValueError, OSError, RuntimeError, subprocess.SubprocessError) as error:
        print(f"Notification setup failed: {failure_message(error)}", file=sys.stderr)
        return 1
    finally:
        if created_device:
            try:
                simctl("shutdown", created_device)
            except subprocess.SubprocessError:
                pass
            simctl("delete", created_device)


if __name__ == "__main__":
    sys.exit(main())
