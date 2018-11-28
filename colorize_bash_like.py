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
    # \x1b[31;4mHello\x1b[0m
    string = sub(r'<PURPLE>', f'{Fore.BLUE}\\002', string)
    string = sub(r'<GREEN>', f'{Fore.GREEN}\\002', string)
    string = sub(r'<WHITE>', f'{Fore.WHITE}\\002', string)
    string = sub(r'<CYAN>', f'{Fore.CYAN}\\002', string)
    string = sub(r'<RED>', f'{Fore.RED}\\002', string)
    string = sub(r'<YELLOW>', f'{Fore.YELLOW}\\002', string)
    string = sub(r'<BLUE>', f'{Fore.BLUE}\\002', string)
    string = sub(r'<MAGNENTA>', f'{Fore.MAGENTA}\\002', string)

    # Symbol substitutions
    string = sub(r'<SYM:UP>', '↑', string)
    string = sub(r'<SYM:DOWN>', '↓', string)
    string = sub(r'<SYM:ADD>', '+', string)
    string = sub(r'<SYM:CHG>', 'Δ', string)
    string = sub(r'<SYM:UNTRACKED>', '…', string)

    return string


if __name__ == '__main__':
    print(
        colorize(' '.join(argv[1:])).replace('\x1b', '\\001\\x1b')
    )
