from subprocess import check_output, DEVNULL
from os import environ, chdir, getcwd
from os.path import join, isfile
from tempfile import gettempdir
from platform import platform
from sys import stderr, argv
from time import time
_UPDATE_FILE_LOCATION = join(gettempdir(), '.next_update_utime')


def should_update(has_internet) -> bool:
    # Don't update if we don't have internet
    if not has_internet:
        return False

    current_time = time()

    if not isfile(_UPDATE_FILE_LOCATION):
        with open(_UPDATE_FILE_LOCATION, 'w') as f:
            f.write('0')

    # Get next update time:
    with open(_UPDATE_FILE_LOCATION, 'r') as f:
        next_update_utime = float(f.read())

    return current_time >= next_update_utime


def update_catelab() -> None:
    if 'CATLAB_SOURCE_DIR' not in environ:
        print("Update scheduled, but not updating because CATLAB_SOURCE_DIR is not set.")
        return

    source_dir = environ['CATLAB_SOURCE_DIR']
    current_dir = getcwd()

    update_text = '\nUpdating ＣＡＴＥＬＡＢ...\n'
    if 'Windows' in platform():
        update_text = update_text.replace('ＣＡＴＥＬＡＢ', 'C A T E L A B')
    stderr.write(update_text)
    stderr.flush()

    # Update and reinstall
    chdir(source_dir)
    check_output('git pull'.split(), universal_newlines=True)
    if 'Windows' in platform():
        check_output('powershell.exe -noprofile ./install.ps1'.split(), universal_newlines=True, stderr=DEVNULL)
    else:
        check_output('./install.sh'.split(), universal_newlines=True, stderr=DEVNULL)

    chdir(current_dir)
    stderr.write('Update complete.\n')
    stderr.flush()

    set_next_update_utime()


def set_next_update_utime() -> None:
    current_time = time()
    next_update_utime = time() + 21600  # + 6 hours

    with open(_UPDATE_FILE_LOCATION, 'w') as f:
        f.write(str(next_update_utime))


if __name__ == '__main__':
    has_internet = argv[1] == 'True'

    if should_update(has_internet):
        update_catelab()

