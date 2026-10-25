#!/usr/bin/env python3
"""Print a fresh Localhost test-user custom token without resetting test data."""
import argparse
import json
import sys
import urllib.error
import urllib.parse
import urllib.request


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--account-id", default="mock-manager-with-data")
    parser.add_argument("--api-base-url", default="http://localhost:8080")
    args = parser.parse_args()
    base = urllib.parse.urlsplit(args.api_base_url)
    if (
        base.scheme != "http"
        or base.hostname not in ("localhost", "127.0.0.1", "::1")
        or base.username is not None
        or base.password is not None
        or base.path not in ("", "/")
        or base.query
        or base.fragment
    ):
        parser.error("Use a local HTTP backend origin, such as http://localhost:8080")
    if not args.account_id.strip():
        parser.error("Account ID must not be empty")
    request = urllib.request.Request(
        args.api_base_url.rstrip("/") + "/admin/login",
        data=json.dumps({"id": args.account_id}).encode(),
        headers={"Content-Type": "application/json"},
        method="POST",
    )
    try:
        with urllib.request.urlopen(request, timeout=10) as response:
            payload = json.load(response)
    except urllib.error.HTTPError as error:
        sys.exit(f"Local test login failed (HTTP {error.code}); check the test account and admin endpoint configuration")
    except (urllib.error.URLError, TimeoutError):
        sys.exit("Cannot reach the local backend; start it before logging in")
    except (ValueError, UnicodeError):
        sys.exit("Local login returned invalid JSON")
    token = payload.get("token") if isinstance(payload, dict) else None
    if not isinstance(token, str) or not token or any(character.isspace() for character in token):
        sys.exit("Local login returned no valid custom token")
    sys.stdout.write(token + "\n")


if __name__ == "__main__":
    main()
