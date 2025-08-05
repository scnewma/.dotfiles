import json
import os
import subprocess
from pathlib import Path

from kitty.boss import Boss

try:
    from projects_local import format_tab_title
except ImportError:

    def format_tab_title(title: str) -> str:
        return title


FZF_BIN = "/opt/homebrew/bin/fzf"


def main(args: list[str]) -> str:
    """
    Launches fzf to select a project directory from the provided directories.
    If the provided directory ends with a / then the subdirectories of that
    directory are included in the search, otherwise the directory itself is
    included.
    """
    dirs = args[1:]

    home = Path.home()

    projects = []
    for dir in dirs:
        path = Path(dir)
        if dir.endswith("/"):
            for entry in path.iterdir():
                if entry.is_dir():
                    projects.append(pretty_path(entry, home))
        else:
            projects.append(pretty_path(path, home))

    p = subprocess.Popen(
        [FZF_BIN, "--header='Select Project.'"],
        stdin=subprocess.PIPE,
        stdout=subprocess.PIPE,
    )
    stdin = "\n".join(projects).encode("utf-8")
    output = p.communicate(input=stdin)[0].decode("utf-8").strip()
    return output


def handle_result(
    args: list[str], answer: str, target_window_id: int, boss: Boss
) -> None:
    if not answer:
        return

    tab_title = os.path.basename(answer)
    tab_title = format_tab_title(tab_title)

    # focus tab if it exists
    for title, id in get_tabs(boss):
        if title != tab_title:
            continue
        boss.call_remote_control(None, ("focus-tab", "--match", f"id:{id}"))
        return

    # launch new tab
    boss.call_remote_control(
        None, ("launch", "--type", "tab", "--tab-title", tab_title, "--cwd", answer)
    )


def pretty_path(path: Path, home: Path) -> str:
    rel = path.relative_to(home)
    return f"~/{rel}"


def get_tabs(boss: Boss) -> list[tuple[str, int]]:
    output = json.loads(boss.call_remote_control(None, ["ls"]))
    return [(tab["title"], tab["id"]) for tab in output[0]["tabs"]]
