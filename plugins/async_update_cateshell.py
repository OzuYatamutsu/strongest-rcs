from subprocess import check_output, DEVNULL
from os import chdir, getcwd, environ
from sys import stderr, argv, path
from platform import platform
from time import time

path.append(environ['CATESHELL_HOME'])
from cateshell_store import CateshellStore  # noqa


def should_update(has_internet: bool) -> bool:
    # Don't update if we don't have internet
    return (
        has_internet
        and time() >= get_next_update_utime()
    )


def update_cateshell() -> None:
    source_dir = get_source_dir()
    if not source_dir:
        print(
            "Update scheduled, but not updating "
            "because CATESHELL_HOME is not set."
        )

        return
    current_dir = getcwd()
    update_text = '\nUpdating ＣＡＴＥＳＨＥＬＬ...\n'
    if 'Windows' in platform():
        update_text = update_text.replace('ＣＡＴＥＳＨＥＬＬ', 'C A T E S H E L L')
    stderr.write(update_text)
    stderr.flush()

    # Update and reinstall
    chdir(source_dir)
    check_output('git pull'.split(), universal_newlines=True)
    if 'Windows' in platform():
        check_output(
            'powershell.exe -noprofile ./install.ps1'.split(),
            universal_newlines=True, stderr=DEVNULL
        )
    else:
        check_output(
            './install.sh'.split(),
            universal_newlines=True, stderr=DEVNULL
        )

    chdir(current_dir)
    stderr.write('Update complete.\n')
    stderr.write('\n')
    stderr.flush()

    set_next_update_utime()


def set_next_update_utime() -> None:
    # Now + 6 hours
    CateshellStore().write_config_key(
        'NEXT_UPDATE_UTIME', str(time() + 21600)
    )


def get_next_update_utime() -> float:
    result = CateshellStore().load_config_key(
        'NEXT_UPDATE_UTIME'
    )

    if not result:
        return 0
    return float(result)


def get_source_dir() -> str:
    return CateshellStore().load_config_key(
       'CATESHELL_SOURCE_DIR'
    )


if __name__ == '__main__':
    has_internet = argv[1] == 'True'

    if should_update(has_internet):
        update_cateshell()