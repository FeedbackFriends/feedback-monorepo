import importlib.util
from pathlib import Path
import re
import subprocess
import tempfile
import unittest
from unittest.mock import patch


SPEC = importlib.util.spec_from_file_location(
    "notification_runner", Path(__file__).resolve().parents[1] / "test-notifications.py"
)
runner = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(runner)


class NotificationCopyTests(unittest.TestCase):
    def test_english_expectations_preserve_user_title_and_all_counts(self):
        for count in [0, 1, 2, 99]:
            with self.subTest(count=count), tempfile.TemporaryDirectory() as directory:
                title = 'Weekly 100% sync (A+B)'
                with patch.object(runner.subprocess, 'run') as run:
                    runner.maestro('device', runner.FLOW, Path(directory),
                                   SESSION_TITLE=title, FEEDBACK_COUNT=str(count))
                arguments = run.call_args.args[0]
                self.assertIn(f'SESSION_TITLE_REGEX={re.escape(title)}', arguments)
                expected = f'New feedback for ‘{title}’ · Responses: {count}'
                self.assertIn(f'NOTIFICATION_BODY_REGEX=(?s).*{re.escape(expected)}.*', arguments)


class InstallationTests(unittest.TestCase):
    def test_recovers_when_new_simulator_installation_service_becomes_ready(self):
        startup_error = subprocess.CalledProcessError(
            2, "simctl install", output="IXErrorDomain: Failed to create promise."
        )
        with patch.object(runner, "simctl", side_effect=[startup_error, ""]) as install:
            with patch.object(runner.time, "sleep"):
                runner.install_app("isolated-device", Path("App.app"))
        self.assertEqual(install.call_count, 2)

    def test_unrelated_installation_failure_is_preserved_without_retry(self):
        error = subprocess.CalledProcessError(1, "simctl install", output="Invalid app bundle")
        with patch.object(runner, "simctl", side_effect=error) as install:
            with self.assertRaises(subprocess.CalledProcessError) as raised:
                runner.install_app("isolated-device", Path("App.app"))
        self.assertIs(raised.exception, error)
        self.assertEqual(install.call_count, 1)

    def test_persistent_startup_failure_remains_a_failure(self):
        error = subprocess.CalledProcessError(
            2, "simctl install", output="IXErrorDomain: Failed to locate promise."
        )
        with patch.object(runner, "simctl", side_effect=error) as install:
            with patch.object(runner.time, "sleep"):
                with self.assertRaises(subprocess.CalledProcessError):
                    runner.install_app("isolated-device", Path("App.app"))
        self.assertEqual(install.call_count, 3)


class BackendPreparationTests(unittest.TestCase):
    def test_existing_backend_login_does_not_seed_or_reset(self):
        from io import BytesIO
        from unittest.mock import MagicMock
        response = MagicMock()
        response.__enter__.return_value = BytesIO(b'{"status":"UP"}')
        with patch.object(runner, 'urlopen', return_value=response), patch.object(runner, 'backend_request') as request:
            request.side_effect = [{'session': {'accessToken': 'private-token'}}, {'managerData': {}}]
            token = runner.prepare_backend(skip_start=True)
        self.assertEqual(token, 'private-token')
        self.assertEqual(request.call_args_list[0].args, ('POST', '/admin/login'))
        self.assertEqual(request.call_args_list[1].args, ('GET', '/bootstrap'))
        self.assertEqual(request.call_count, 2)

    def test_missing_manager_fails_instead_of_faking_a_bootstrap(self):
        from io import BytesIO
        from unittest.mock import MagicMock
        response = MagicMock()
        response.__enter__.return_value = BytesIO(b'{"status":"UP"}')
        with patch.object(runner, 'urlopen', return_value=response), patch.object(runner, 'backend_request') as request:
            request.side_effect = [{'session': {'accessToken': 'private-token'}}, {'managerData': None}]
            with self.assertRaisesRegex(RuntimeError, '--seed-manager'):
                runner.prepare_backend(skip_start=True)
        self.assertEqual(request.call_count, 2)

    def test_real_backend_ids_are_used_and_session_is_visible_in_bootstrap(self):
        activity_id = '00000000-0000-0000-0000-000000000101'
        event_id = '00000000-0000-0000-0000-000000000202'
        with patch.object(runner, 'backend_request') as request:
            request.side_effect = [
                {'id': activity_id}, {'id': event_id},
                {'managerData': {'activities': [{'id': activity_id, 'events': [{'id': event_id}]}]}},
            ]
            self.assertEqual(runner.create_session('private-token', 'Weekly 100% sync'), (activity_id, event_id))
        self.assertEqual(request.call_args_list[0].kwargs['payload']['title'], 'Weekly 100% sync')
        self.assertFalse(request.call_args_list[0].kwargs['payload']['sendEmails'])
        self.assertEqual(request.call_args_list[1].kwargs['payload']['activityId'], activity_id)
        self.assertEqual(request.call_args_list[2].args, ('GET', '/bootstrap'))

    def test_failed_session_preparation_deletes_only_its_activity(self):
        activity_id = '00000000-0000-0000-0000-000000000101'
        with patch.object(runner, 'backend_request') as request:
            request.side_effect = [{'id': activity_id}, RuntimeError('Session creation failed'), None]
            with self.assertRaisesRegex(RuntimeError, 'Session creation failed'):
                runner.create_session('private-token', 'Test')
        self.assertEqual(request.call_args_list[-1].args, ('DELETE', f'/activity/{activity_id}'))

    def test_missing_session_in_backend_bootstrap_fails_and_cleans_up(self):
        activity_id = '00000000-0000-0000-0000-000000000101'
        with patch.object(runner, 'backend_request') as request:
            request.side_effect = [
                {'id': activity_id}, {'id': '00000000-0000-0000-0000-000000000202'},
                {'managerData': {'activities': []}}, None,
            ]
            with self.assertRaisesRegex(RuntimeError, 'missing from the real backend'):
                runner.create_session('private-token', 'Test')
        self.assertEqual(request.call_args_list[-1].args, ('DELETE', f'/activity/{activity_id}'))

    def test_launch_uses_existing_local_login_without_credential_arguments(self):
        with patch.object(runner.subprocess, 'run') as run:
            runner.launch_manager('device')
        self.assertEqual(run.call_args.kwargs['env']['SIMCTL_CHILD_LETSGROW_LOCAL_TEST_ACCOUNT'], 'manager')
        self.assertNotIn('E2E_CUSTOM_TOKEN', ' '.join(run.call_args.args[0]))
