from colorama import init, Fore, Style
from sys import argv
from re import sub
init(autoreset=True)


def colorize(string):
    string = sub(
        r'<BOLD:(.+?)>(.+?)($|<)',
        Style.BRIGHT + r'<\1>\2' + Style.RESET_ALL + r'\3',
        string
    )
    string = sub(r'<PURPLE>', Fore.CYAN, string)
    string = sub(r'<GREEN>', Fore.GREEN, string)
    string = sub(r'<WHITE>', Fore.WHITE, string)
    string = sub(r'<CYAN>', Fore.CYAN, string)
    string = sub(r'<RED>', Fore.RED, string)
    string = sub(r'<YELLOW>', Fore.YELLOW, string)
    string = sub(r'<BLUE>', Fore.BLUE, string)
    string = sub(r'<MAGNENTA>', Fore.MAGENTA, string)

    # Symbol substitutions (will substitute in shell land)
    # string = sub(r'<SYM:UP>', '<U>', string)
    # string = sub(r'<SYM:DOWN>', '<D>', string)
    # string = sub(r'<SYM:ADD>', '<A>', string)
    # string = sub(r'<SYM:CHG>', '<C>', string)
    # string = sub(r'<SYM:UNTRACKED>', '<UT>', string)

    return string


if __name__ == '__main__':
    print(
        colorize(' '.join(argv[1:])).replace('\x1b', '\\x1b')
    )
