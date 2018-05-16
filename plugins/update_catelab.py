from tempfile import gettempdir
from time import time
from sys import stderr
from os import environ, chdir, getcwd
from os.path import join, isfile
from subprocess import check_output, DEVNULL
from platform import platform
_UPDATE_FILE_LOCATION = join(gettempdir(), '.next_update_utime')


def should_update() -> bool:
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

    stderr.write('\n\n')
    stderr.write('Updating ＣＡＴＥＬＡＢ...\n')
    stderr.flush()

    # Update and reinstall
    chdir(source_dir)
    check_output('git pull'.split(), universal_newlines=True)
    if 'Windows' in platform():
        check_output('./install.ps1'.split(), universal_newlines=True, stderr=DEVNULL)
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
    if should_update():
        update_catelab()

