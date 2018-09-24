from git_support import shell_format
from os import getcwd
from colorama import init
from pathlib import Path
from platform import node
from getpass import getuser

print(f'{getuser()}@{node()} {getcwd().replace(str(Path.home()), "~")} {shell_format()}> ')
