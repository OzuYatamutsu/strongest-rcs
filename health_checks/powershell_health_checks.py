from health_check_base import HealthCheckBase
from re import findall


class PowershellHealthChecks(HealthCheckBase):
    def __init__(self):
        super().__init__()

    def format_for_shell(self, output: str):
        replace_tokens = ['green', 'red', 'blue', 'magenta']
        for replace_token in replace_tokens:
            needle = f'\<{replace_token}\>(?P<value>.*?)\<\/{replace_token}\>'
            values = findall(needle, output)

            while values:
                value = values.pop()
                output = output.replace(
                    f'<{replace_token}>{value}</{replace_token}>',
                    f'Write-Host "{value}" -ForegroundColor {replace_token}'
                )

        return f'{output}'\
            .replace('%', '%%')\
            .replace('✓', 'OK')\
            .replace('✗', 'BAD')

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
        print(
            f"echo {'0' if self.net_check_status else '-1'} "
            "> ~/.config/cateshell/.net_check_result"
        )
        print(f"$NET_CMD_STATUS={'0' if self.net_check_status else '-1'}")


if __name__ == '__main__':
    health_checker = PowershellHealthChecks()
    health_checker.run_checks()
