from cateshell_git_support import shell_format
from getpass import getuser
from platform import node
from pathlib import Path
from os import getcwd


def prompt() -> str:
    try:
        git_status = shell_format(prefix=True)
    except Exception:
        # Don't break the prompt on exception
        git_status = ''
    return (
        f'<PURPLE>{getuser()}@{node().split(".")[0]}'  # jinhai@catelab
        f' <GREEN>{getcwd().replace(str(Path.home()), "~")}'  # ~/dev
        f'{git_status}'  # (feature/test|↑1)
        f'<WHITE>> '  # >
    )


if __name__ == '__main__':
    try:
        print(prompt())
    except KeyboardInterrupt:
        pass

