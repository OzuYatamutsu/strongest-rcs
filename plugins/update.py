from tempfile import gettempdir
from time import time
from os import environ, chdir, getcwd
from os.path import join, isfile
from subprocess import check_output


_UPDATE_FILE_LOCATION = join('{temp_dir}', '.next_update_utime')


def should_update() -> bool:
    current_time = time()

    if not isfile(_UPDATE_FILE_LOCATION):
        with open(_UPDATE_FILE_LOCATION, 'w') as f:
            f.write('0')

    # Get next update time
    with open(_UPDATE_FILE_LOCATION, 'r') as f:
        next_update_utime = int(f.read())

    return current_time >= next_update_utime

def update() -> None:
    if 'CATLAB_SOURCE_DIR' not in environ:
        print('Update scheduled, but not updating because CATLAB_SOURCE_DIR is not set.')
        return

    source_dir = environ['CATLAB_SOURCE_DIR']
    current_dir = getcwd()

    print("Updating ＣＡＴＥＬＡＢ...")

    # Update and reinstall
    chdir(source_dir)
    check_output('git pull'.split(), universal_newlines=True)
    from install import catelab_install
    catelab_install()

    chdir(current_dir)
    print("Update complete.")

def set_next_update_utime() -> None:
    current_time = time()
    next_update_utime = time() + 21600  # + 6 hours

    with open(_UPDATE_FILE_LOCATION, 'w') as f:
        f.write(str(next_update_utime))


if __name__ == '__main__':
    if should_update():
        update()

