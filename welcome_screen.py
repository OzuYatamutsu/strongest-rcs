from health_checks.health_check_base import HealthCheckBase
from subprocess import check_output, Popen
from colorama import init, Fore
from socket import gethostname
from platform import platform 
from datetime import datetime
from getpass import getuser
from pytz import reference
from os.path import join
from os import listdir
from sys import argv
init(autoreset=True)


def main(base_config_dir: str):
    # Health checker
    health_checker = HealthCheckBase()    

    # Cat art, datetime, welcome text
    print_header(base_config_dir)
    print()

    # Health checks (internet status, space check, ...)
    print_status_report(health_checker)
    have_internet_connection = health_checker.net_check_status

    # Run all plugins in plugin directory (lexographically)
    run_and_print_plugin_results(base_config_dir, have_internet_connection)
    print()

    shell_agnostic_print(
        f"What will your {Fore.MAGENTA}first sequence of the day{Fore.RESET} be?"
    )


def print_header(base_config_dir: str) -> None:
    # Print cat header
    with open(join(base_config_dir, "cat_header"), 'r') as f:
        for line in f:
            shell_agnostic_print(line.strip('\n'))

    # Welcome text
    shell_agnostic_print(
        f"Yo! Welcome to {Fore.BLUE}ＣＡＴＥＬＡＢ{Fore.RESET} on {Fore.MAGENTA}{gethostname()}{Fore.RESET}, {Fore.BLUE}{getuser()}!\n"
        f"It's currently {Fore.GREEN}{ _get_humanized_timestamp()}."
    )


def print_status_report(health_checker=None) -> None:
    health_checker = health_checker or HealthCheckBase()
    shell_agnostic_print(f"{Fore.MAGENTA}Status report!!")

    # Run status checks in the order defined in run_checks
    for line in health_checker.run_checks():
        shell_agnostic_print(_colorize(line))


def run_and_print_plugin_results(base_config_dir: str, has_internet: bool) -> None:
    plugin_dir = join(base_config_dir, 'plugins')
    for plugin in [join(plugin_dir, plugin) for plugin in listdir(plugin_dir) if plugin.endswith('.py')]:
        if 'async' in plugin:
            Popen(['python3', plugin, str(has_internet)])
            result = None
        else:
            result = check_output(['python3', plugin, str(has_internet)], universal_newlines=True)
        if not result:
            continue
        for line in result.strip('\n').split('\n'):
            shell_agnostic_print(_colorize(line))


# HELPERS
def shell_agnostic_print(text) -> None:
    if 'Windows' not in platform():
        print(text)
        return

    print(text\
        .replace('ＣＡＴＥＬＡＢ', 'C A T E L A B')\
        .replace(Fore.BLUE, Fore.CYAN)\
        .replace(Fore.MAGENTA, Fore.RED)\
        .replace('✓', '[OK]')\
        .replace('✗', '[NG]')
    )


def _colorize(string_with_colors) -> str:
    replace_kv = {
        '<black>': Fore.BLACK,
        '<red>': Fore.RED,
        '<green>': Fore.GREEN,
        '<yellow>': Fore.YELLOW,
        '<blue>': Fore.BLUE,
        '<magenta>': Fore.MAGENTA,
        '<cyan>': Fore.CYAN,
        '<white>': Fore.WHITE,
        '<reset>': Fore.RESET
    }

    for color_str, color_enum in replace_kv.items():
        string_with_colors = string_with_colors.replace(color_str, color_enum)
    return string_with_colors


def _get_humanized_timestamp():
    current_datetime = datetime.now()
    current_timezone: str = reference.LocalTimezone().tzname(current_datetime)
    return current_datetime.strftime('%A, %B %d %Y at %I:%M:%S %p ') + current_timezone 


if __name__ == "__main__":
    # Pass in base config directory as argument
    main(argv[1])

