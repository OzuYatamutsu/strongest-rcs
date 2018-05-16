from subprocess import check_output, STDOUT, CalledProcessError, DEVNULL 
from health_check_base import HealthCheckBase
from os.path import isfile
from re import findall


class PowershellHealthChecks(HealthCheckBase):
    def __init__(self):
        super().__init__()

    def format_for_shell(self, output: str):
        replace_tokens = ['green', 'red', 'blue', 'magenta']
        for replace_token in replace_tokens:
            needle = '\<{token}\>(?P<value>.*?)\<\/{token}\>'.format(token=replace_token)
            values = findall(needle, output)

            while values:
                value = values.pop()
                output = output.replace(
                    '<{token}>{value}</{token}>'.format(token=replace_token, value=value),
                    'Write-Host "{value}" -ForegroundColor {token}'.format(token=replace_token, value=value)
                )

        return '{output}'.format(output=output).replace('%', '%%').replace('✓', 'OK').replace('✗', 'BAD')

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
        print("echo {net_check_result} > ~/.config/cateshell/.net_check_result".format(net_check_result=('0' if self.net_check_status else '-1')))
        print("$NET_CMD_STATUS={status}".format(status=('0' if self.net_check_status else '-1')))

if __name__ == '__main__':
    health_checker = PowershellHealthChecks()
    health_checker.run_checks()

