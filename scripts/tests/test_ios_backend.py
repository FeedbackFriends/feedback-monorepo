"""Verify backend preparation without starting containers or accessing production."""

import json
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest


SCRIPT = Path(__file__).resolve().parents[1] / "ios-backend"


class IOSBackendTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        (self.root / "scripts").mkdir()
        shutil.copy2(SCRIPT, self.root / "scripts/ios-backend")
        config = self.root / "ios-app/App/Config"
        config.mkdir(parents=True)
        (config / "localhost.xcconfig").write_text("API_SCHEME = http\nAPI_BASE_URL = localhost:8080\n")
        (config / "production.xcconfig").write_text("API_SCHEME = https\nAPI_BASE_URL = api.letsgrow.dk\n")
        (self.root / "backend").mkdir()
        self.bin = self.root / "bin"
        self.bin.mkdir()
        self.log = self.root / "calls.jsonl"
        self.env = dict(os.environ, PATH=f"{self.bin}{os.pathsep}{os.environ['PATH']}",
                        CALL_LOG=str(self.log), DOCKER_HOST="unix:///local/docker.sock")
        stub = """#!/usr/bin/env python3
import json, os, sys
from pathlib import Path
name = Path(sys.argv[0]).name
args = sys.argv[1:]
with open(os.environ['CALL_LOG'], 'a') as output:
    output.write(json.dumps([name, *args]) + '\\n')
if name == 'docker' and 'config' in args:
    print(json.dumps({'services': {'api': {'platform': 'linux/arm64', 'image': 'nicolaidam/feedback-api:local'}}}))
elif name == 'docker' and 'ps' in args:
    print('api-container')
elif name == 'docker' and 'inspect' in args:
    print(os.environ.get('API_STATE', 'running'))
elif name == 'curl':
    print(json.dumps({'status': os.environ.get('HEALTH_STATUS', 'UP')}))
elif name == 'gradlew' and os.environ.get('BUILD_FAIL'):
    raise SystemExit(1)
"""
        for path in [self.bin / "docker", self.bin / "curl", self.root / "backend/gradlew"]:
            path.write_text(stub)
            path.chmod(0o755)

    def run_script(self, mode, **env):
        return subprocess.run([str(self.root / "scripts/ios-backend"), mode], cwd=self.root,
                              env=dict(self.env, **env), text=True, capture_output=True)

    def calls(self):
        return [json.loads(line) for line in self.log.read_text().splitlines()] if self.log.exists() else []

    def test_local_build_starts_only_api_and_database_without_reset(self):
        result = self.run_script("localhost")
        self.assertEqual(result.returncode, 0, result.stderr)
        calls = self.calls()
        build = next(call for call in calls if call[0] == "gradlew")
        self.assertIn(":api:jibDockerBuild", build)
        self.assertIn("-Djib.from.platforms=linux/arm64", build)
        up = next(call for call in calls if call[0] == "docker" and "up" in call)
        self.assertEqual(up[-7:], ["up", "-d", "--no-build", "--pull", "never", "db", "api"])
        self.assertFalse(any("down" in call or "reset" in call or "--volumes" in call for call in calls))
        self.assertIn("API_URL=http://localhost:8080", result.stdout)

    def test_production_only_checks_deployed_health(self):
        result = self.run_script("production")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual([call[0] for call in self.calls()], ["curl"])
        self.assertEqual(self.calls()[0][-1], "https://api.letsgrow.dk/actuator/health")

    def test_production_down_is_an_error(self):
        result = self.run_script("production", HEALTH_STATUS="DOWN")
        self.assertEqual(result.returncode, 1)
        self.assertIn("Backend health check failed", result.stderr)

    def test_failed_build_does_not_start_services(self):
        self.assertEqual(self.run_script("localhost", BUILD_FAIL="1").returncode, 1)
        self.assertFalse(any("up" in call for call in self.calls()))

    def test_crash_loop_is_reported_without_waiting_or_resetting(self):
        result = self.run_script("localhost", HEALTH_STATUS="DOWN", API_STATE="restarting")
        self.assertEqual(result.returncode, 1)
        self.assertIn("container is restarting", result.stderr)
        self.assertIn("Database contents were preserved", result.stderr)
        self.assertFalse(any("down" in call or "--volumes" in call for call in self.calls()))

    def test_remote_docker_is_rejected_before_build(self):
        self.assertEqual(self.run_script("localhost", DOCKER_HOST="ssh://remote").returncode, 1)
        self.assertFalse(any(call[0] == "gradlew" for call in self.calls()))

    def test_wrong_environment_configuration_is_rejected(self):
        (self.root / "ios-app/App/Config/localhost.xcconfig").write_text(
            "API_SCHEME = https\nAPI_BASE_URL = api.letsgrow.dk\n"
        )
        self.assertNotEqual(self.run_script("localhost").returncode, 0)
        self.assertEqual(self.calls(), [])

    def test_unknown_mode_has_no_side_effects(self):
        self.assertEqual(self.run_script("invalid").returncode, 2)
        self.assertEqual(self.calls(), [])


if __name__ == "__main__":
    unittest.main()
