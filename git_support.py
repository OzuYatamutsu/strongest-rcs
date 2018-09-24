from colorama import init, Fore
from git import Repo
init(autoreset=True)


def get_head_sha(repo=None, num_chars=7) -> str:
    repo = repo or Repo('.')
    return repo.commit().hexsha[:num_chars]


def get_current_branch(repo=None) -> str:
    repo = repo or Repo('.')

    try:
        return repo.active_branch.name
    except TypeError:
        # Likely detached HEAD. Return hash.
        return f':{get_head_sha(repo=repo)}'


def get_num_unpushed_commits(repo=None) -> int:
    repo = repo or Repo('.')

    current_branch = get_current_branch(repo=repo)
    if current_branch.startswith(':'):
        # Detached head. This doesn't apply.
        return 0
    return sum(1 for commit in repo.iter_commits(
        f'origin/{current_branch}..{current_branch}'
    ))


def get_num_unpulled_commits(repo=None) -> int:
    repo = repo or Repo('.')

    current_branch = get_current_branch(repo=repo)
    if current_branch.startswith(':'):
        # Detached head. This doesn't apply.
        return 0
    return sum(1 for commit in repo.iter_commits(
        f'{current_branch}..origin/{current_branch}'
    ))


def get_num_added_files(repo=None) -> int:
    repo = repo or Repo('.')
    return len(repo.commit().diff())


def get_num_untracked_files(repo=None) -> int:
    repo = repo or Repo('.')
    return len(repo.untracked_files)


# Format:
def shell_format() -> str:
    repo = Repo('.')
    current_branch = get_current_branch(repo=repo)
    num_unpushed_commits = get_num_unpushed_commits(repo=repo)
    num_unpulled_commits = get_num_unpulled_commits(repo=repo)
    num_added_files = get_num_added_files(repo=repo)
    num_untracked_files = get_num_untracked_files(repo=repo)

    return (
        f'{Fore.RESET}(' +
        f'{Fore.GREEN}{current_branch}' +
        f'{Fore.RESET}|' +
        (f'{Fore.GREEN}↑{num_unpushed_commits}' if num_unpushed_commits else '') +
        (f'{Fore.GREEN}↓{num_unpulled_commits}' if num_unpulled_commits else '') +
        (f'{Fore.GREEN}+{num_added_files}' if num_added_files else '') +
        (f'{Fore.CYAN}…{num_untracked_files}' if num_untracked_files else '') +
        f'{Fore.RESET})'
    )

if __name__ == '__main__':
    print(shell_format())
