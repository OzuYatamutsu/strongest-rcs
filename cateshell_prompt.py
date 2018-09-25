from cateshell_git_support import shell_format
from colorama import init, Fore
from getpass import getuser
from platform import node
from pathlib import Path
from os import getcwd
init(autoreset=True)


def prompt() -> str:
    return (
        f'{Fore.MAGENTA}{getuser()}@{node()}'  # jinhai@catelab
        f' {Fore.GREEN}{getcwd().replace(str(Path.home()), "~")}'  # ~/dev
        f'{shell_format(prefix=True)}'  # (feature/test|↑1)
        f'> '  # >
    )

if __name__ == '__main__':
    print(prompt().replace('\x1b', '\\x1b'))
