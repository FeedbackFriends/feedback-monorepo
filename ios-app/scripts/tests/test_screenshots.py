from pathlib import Path
import runpy
import unittest
from unittest.mock import MagicMock, patch

runner = runpy.run_path(str(Path(__file__).parents[1] / 'screenshots'))
capture = runner['capture']


class ScreenshotRunnerTests(unittest.TestCase):
    def fake_xcode(self, build=None, counts=None):
        client = MagicMock()
        responses = {
            'XcodeOpenWorkspace': {'workspaceIdentifier': 'test-workspace'},
            'XcodeListRunDestinations': {'destinations': [
                {'isActive': True, 'isSimulator': True, 'isEligible': True, 'displayTitle': 'iPhone'}]},
            'BuildProject': build or {'errors': [], 'buildResult': 'The build succeeded'},
            'RunSomeTests': {'summary': 'test result', 'counts': counts or {'total': 1, 'passed': 1},
                             'fullSummaryPath': '/tmp/results'},
        }
        client.call.side_effect = lambda name, **kwargs: responses.get(name, {})
        return client

    def test_failed_build_restores_plan_and_does_not_run_capture(self):
        client = self.fake_xcode(build={'errors': [{'message': 'compile error'}], 'buildResult': 'Failed'})
        with patch.dict(capture.__globals__, Xcode=MagicMock(return_value=client)):
            client.__enter__.return_value = client
            with self.assertRaisesRegex(RuntimeError, 'Build failed'):
                capture()
        self.assertNotIn('RunSomeTests', [call.args[0] for call in client.call.call_args_list])
        self.assertEqual(client.call.call_args.kwargs['testPlanName'], 'UnitTests')

    def test_failed_capture_stops_before_publication(self):
        client = self.fake_xcode(counts={'total': 1, 'passed': 0})
        with patch.dict(capture.__globals__, Xcode=MagicMock(return_value=client)):
            client.__enter__.return_value = client
            with self.assertRaisesRegex(RuntimeError, 'no images published'):
                capture()
        self.assertEqual(client.call.call_args.kwargs['testPlanName'], 'UnitTests')

    def test_physical_device_is_rejected(self):
        client = self.fake_xcode()
        client.call.side_effect = lambda name, **kwargs: (
            {'workspaceIdentifier': 'test'} if name == 'XcodeOpenWorkspace' else
            {'destinations': [{'isActive': True, 'isSimulator': False, 'isEligible': True}]}
            if name == 'XcodeListRunDestinations' else {})
        with patch.dict(capture.__globals__, Xcode=MagicMock(return_value=client)):
            client.__enter__.return_value = client
            with self.assertRaisesRegex(RuntimeError, 'simulator'):
                capture()
        self.assertNotIn('BuildProject', [call.args[0] for call in client.call.call_args_list])
