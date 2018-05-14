from datetime import datetime, time


class HealthCheckBase:
    """Interface to run OS health checks to show in shell welcome text"""

    _CHECK_RESULT_STATUS_STRINGS = {
        'net': {
            True: "Your internet connection looks <green>OK</green>, dood!",
            False: "Your internet connection looks <red>degraded</red>, dood."
        },
        'space': {
            True: "You have <green>plenty of space</green> on / (<green>{percent}</green> full)!",
            False: "You're <red>runnin' out of space</red> on / (<red>{percent}</red> full)!"
        },
        'time': {
            True: "It's <green>a good day for science</green>!",
            False: "It's <red>late</red>. You should go to bed."
        }
    }

    _net_check_endpoint = 'google.com'
    _space_check_threshold = 20
    _time_check_bounds = (5, 23)

    def __init__(self):
        self.net_status = None

    def check_network(self) -> str:
        """Checks network connectivity."""
        raise NotImplementedError

    def check_space(self, root='/') -> str:
        """
        Checks to see if free space available on
        the root fs is less than a threshold.
        """

        free_space_percent = (disk_usage(root).free / disk_usage(root).total) * 100

        return (self._prepend_state(
            FishHealthChecks._CHECK_RESULT_STATUS_STRINGS['space'][True],
            True
        ) if free_space_percent >= FishHealthChecks._space_check_threshold else self._prepend_state(
            FishHealthChecks._CHECK_RESULT_STATUS_STRINGS['space'][False],
            False
        )).format(percent=str(int(round(free_space_percent, 0))) + '%')

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

