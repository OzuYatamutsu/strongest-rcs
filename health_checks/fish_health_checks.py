from health_check_base import HealthCheckBase
from subprocess import check_output, STDOUT, CalledProcessError
from shutil import disk_usage
from os.path import isfile


class FishHealthChecks(HealthCheckBase):
    def __init__(self):
        super().__init__()

    def check_network(self) -> str:
        """Checks network connectivity."""

        net_command = (
            "nc -zw1 google.com 80 2>/dev/null" if not isfile("/etc/redhat-release")
            else "nc -w1 google.com 80 --send-only </dev/null 2>/dev/null"
        )

        try:
            result = check_output(
                net_command.split(),
                stderr=STDOUT,
                universal_newlines=True
            )
        except CalledProcessError:
            return self._prepend_state(
                FishHealthChecks._CHECK_RESULT_STATUS_STRINGS['net'][False],
                False
            )

        return self._prepend_state(
            FishHealthChecks._CHECK_RESULT_STATUS_STRINGS['net'][True],
            True
        )

    def format_for_shell(self):
        raise NotImplementedError

    def run_checks(self):
        health_check_results = [
            self.check_network(),
            self.check_space(),
            self.check_time()
        ]

        for line in health_check_results:
            print(self.format_for_shell(line))

    def _prepend_state(self, result_string: str, result: bool):
        return (
            ("<green>✓</green> " + result_string) if result
            else ("<red>✗</red> " + result_string)
        )
