from git import Repo, InvalidGitRepositoryError


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


def get_num_changed_files(repo=None) -> int:
    repo = repo or Repo('.')
    return sum(1 for diff in repo.index.diff(None))


def get_num_added_files(repo=None) -> int:
    repo = repo or Repo('.')
    return len(repo.commit().diff())


def get_num_untracked_files(repo=None) -> int:
    repo = repo or Repo('.')
    return len(repo.untracked_files)


# Format:
def shell_format(prefix=False) -> str:
    try:
        repo = Repo('.')
    except InvalidGitRepositoryError:
        # Current dir is not a git repo.
        return ''

    current_branch = get_current_branch(repo=repo)
    num_unpushed_commits = get_num_unpushed_commits(repo=repo)
    num_unpulled_commits = get_num_unpulled_commits(repo=repo)
    num_added_files = get_num_added_files(repo=repo)
    num_changed_files = get_num_changed_files(repo=repo)
    num_untracked_files = get_num_untracked_files(repo=repo)
    no_changes = (
        num_unpushed_commits + num_unpulled_commits
        + num_added_files + num_changed_files
        + num_untracked_files
    ) == 0

    prompt = (
        f'{" " if prefix else ""}'
        f'<WHITE>(' +
        f'<BOLD:PURPLE>{current_branch}' +
        f'<WHITE>'
    )

    if not no_changes:
        prompt += '|'
        prompt += (
            f'<GREEN><SYM:UP><WHITE>'  # ↑
            f'{num_unpushed_commits}' if num_unpushed_commits else ''
        )
        prompt += (
            f'<GREEN><SYM:DOWN><WHITE>'  # ↓
            f'{num_unpulled_commits}' if num_unpulled_commits else ''
        )
        prompt += (
            f'<GREEN><SYM:ADD><WHITE>'  # +
            f'{num_added_files}' if num_added_files else ''
        )
        prompt += (
            f'<GREEN><SYM:CHG><WHITE>'  # Δ
            f'{num_changed_files}' if num_changed_files else ''
        )
        prompt += (
            f'<CYAN><SYM:UNTRACKED><WHITE>'  # …
            f'{num_untracked_files}' if num_untracked_files else ''
        )

    prompt += f'<WHITE>)'
    return prompt


if __name__ == '__main__':
    print(shell_format())
