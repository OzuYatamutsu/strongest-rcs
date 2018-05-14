from subprocess import check_output, STDOUT, CalledProcessError, DEVNULL 
from health_check_base import HealthCheckBase
from os.path import isfile
from re import findall


class FishHealthChecks(HealthCheckBase):
    def __init__(self):
        super().__init__()

    def check_network(self) -> str:
        """Checks network connectivity."""

        net_command = (
            "nc -zw1 {endpoint} 80" if not isfile("/etc/redhat-release")
            else "nc -w1 {endpoint} 80 --send-only"
        ).format(endpoint=FishHealthChecks._net_check_endpoint)

        try:
            result = check_output(
                net_command.split(),
                stderr=STDOUT,
                stdin=DEVNULL,
                universal_newlines=True
            )
        except CalledProcessError:
            return self._prepend_state(
                FishHealthChecks._CHECK_RESULT_STATUS_STRINGS['net'][False],
                False
            )

        self.net_check_status = True
        return self._prepend_state(
            FishHealthChecks._CHECK_RESULT_STATUS_STRINGS['net'][True],
            True
        )

    def format_for_shell(self, output: str):
        replace_tokens = ['green', 'red', 'blue', 'magenta']
        for replace_token in replace_tokens:
            needle = '\<{token}\>(?P<value>.*?)\<\/{token}\>'.format(token=replace_token)
            values = findall(needle, output)

            while values:
                value = values.pop()
                output = output.replace(
                    '<{token}>{value}</{token}>'.format(token=replace_token, value=value),
                    '(emphasize_text {token} "{value}")'.format(token=replace_token, value=value)
                )

        return 'echo {output}'.format(output=output).replace('%', '%%')

    def run_checks(self):
        health_check_results = [
            self.check_network(),
            self.check_space(),
            self.check_time()
        ]

        print(self.format_for_shell("<magenta>Status report!!</magenta>"))
        for line in health_check_results:
            print(self.format_for_shell(line))

        # Expose net check result to fs
        print("echo {net_check_result} > ~/.config/fish/.net_check_result".format(net_check_result=('0' if self.net_check_status else '-1')))
        print("set NET_CMD_STATUS {status}".format(status=('0' if self.net_check_status else '-1')))

if __name__ == '__main__':
    health_checker = FishHealthChecks()
    health_checker.run_checks()

