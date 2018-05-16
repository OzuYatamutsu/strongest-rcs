from health_checks.health_check_base import HealthCheckBase
from colorama import init, Fore
from socket import gethostname
from datetime import datetime
from getpass import getuser
from pytz import reference
from os.path import join
from sys import argv
init(autoreset=True)

def echo_welcome_screen(base_config_dir: str):
    # Print cat header
    with open(join(base_config_dir, "cat_header"), 'r') as f:
        for line in f:
            print(line.strip('\n'))

    # Welcome text
    print("Yo! Welcome to {blue}ＣＡＴＥＬＡＢ{norm} on {magenta}{hostname}{norm}, {blue}{user}!".format(
        blue=Fore.BLUE,
        norm=Fore.RESET,
        magenta=Fore.MAGENTA,
        hostname=gethostname(),
        user=getuser()
    ))

    # Datetime
    current_datetime = datetime.now()
    current_timezone: str = reference.LocalTimezone().tzname(current_datetime)

    print("It's currently {green}{datetime}.".format(
        green=Fore.GREEN,
        datetime=current_datetime.strftime('%A, %B %d %Y at %I:%M:%S %p ') + current_timezone 
    ))

    print()
    _print_status_report()
    _run_and_print_plugin_results()

    print("What will your {magenta}first sequence of the day{norm} be?".format(
        magenta=Fore.MAGENTA,
        norm=Fore.RESET
    ))

def _print_status_report():
    print("{magenta}Status report!!".format(
        magenta=Fore.MAGENTA
    ))

    for line in HealthCheckBase().run_checks():
        print(_colorize(line))
    print()

def _run_and_print_plugin_results():
    pass

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

if __name__ == "__main__":
    # Pass in base config directory as argument
    echo_welcome_screen(argv[1])

