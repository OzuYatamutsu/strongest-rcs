from datetime import datetime, time
from shutil import disk_usage
from socket import socket, AF_INET, SOCK_STREAM, setdefaulttimeout, gethostname
from re import findall

class HealthCheckBase:
    """Interface to run OS health checks to show in shell welcome text"""

    _CHECK_RESULT_STATUS_STRINGS = {
        'net': {
            True: "Your internet connection looks <green>OK<reset>, dood!",
            False: "Your internet connection looks degraded<reset>, dood."
        },
        'space': {
            True: "You have <green>plenty of space<reset> on / (<green>{percent}<reset> full)!",
            False: "You're <red>runnin' out of space<reset> on / (<red>{percent}<reset> full)!"
        },
        'time': {
            True: "It's <green>a good day for science<reset>!",
            False: "It's <red>late<reset>. You should go to bed."
        }
    }

    _net_check_endpoint = (
        ('8.8.8.8', 53) if not gethostname().endswith('linkedin.biz')
        else ('1.1.1.1', 80)
    )
    _space_check_threshold = 80
    _time_check_bounds = (5, 23)

    def __init__(self):
        self.net_check_status = False

    def check_network(self) -> str:
        """Checks network connectivity."""
        
        try:
            setdefaulttimeout(1)  # Wait a max of 1 sec
            test_socket = socket(AF_INET, SOCK_STREAM)
            test_socket.connect(HealthCheckBase._net_check_endpoint)
            self.net_check_status = True
        except OSError as e:
            return self._prepend_state(
                HealthCheckBase._CHECK_RESULT_STATUS_STRINGS['net'][False],
                False
            )
        finally:
            test_socket.close()
        
        return self._prepend_state(
            HealthCheckBase._CHECK_RESULT_STATUS_STRINGS['net'][True],
            True
        )

    def check_space(self, root='/') -> str:
        """
        Checks to see if free space available on
        the root fs is less than a threshold.
        """

        used_space_percent = (disk_usage(root).used / disk_usage(root).total) * 100

        return (self._prepend_state(
            HealthCheckBase._CHECK_RESULT_STATUS_STRINGS['space'][True],
            True
        ) if used_space_percent <= HealthCheckBase._space_check_threshold else self._prepend_state(
            HealthCheckBase._CHECK_RESULT_STATUS_STRINGS['space'][False],
            False
        )).format(percent=str(int(round(used_space_percent, 0))) + '%')

    def check_time(self) -> str:
        """
        Checks to see if the current time is after
        a certain hour.
        """
        
        now = datetime.now().time()
        if (
            now >= time(HealthCheckBase._time_check_bounds[0], 0)
            and now <= time(HealthCheckBase._time_check_bounds[1], 0)
        ):
            return self._prepend_state(
                HealthCheckBase._CHECK_RESULT_STATUS_STRINGS['time'][True],
                True
            )

        return self._prepend_state(
            HealthCheckBase._CHECK_RESULT_STATUS_STRINGS['time'][False],
            False
        )

    def run_checks(self):
        return [
            self.check_network(),
            self.check_space(),
            self.check_time()
        ]

    def _prepend_state(self, result_string: str, result: bool):
        return (
            ("<green> ✓<reset> " + result_string) if result
            else ("<red> ✗<reset> " + result_string)
        )

if __name__ == '__main__':
    health_checker = HealthCheckBase()
    print(str(health_checker.run_checks()))

