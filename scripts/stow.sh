#!/usr/bin/env bash
set -euo pipefail

root=$(cd "$(dirname "$0")/.." && pwd)

if (($# == 0)); then
	set -- bat gh git ghostty herdr kitty nvim pi starship tmux zsh
fi

for package in "$@"; do
	if [[ ! -d "$root/$package" || "$package" == */* || "$package" == -* || "$package" == . || "$package" == .. ]]; then
		printf 'Invalid package: %s\n' "$package" >&2
		exit 1
	fi
done

command -v stow >/dev/null
args=("--dir=$root" "--target=$HOME")
for package in "$@"; do
	[[ "$package" == pi ]] || continue

	for directory in "$HOME/.pi" "$HOME/.pi/agent" "$HOME/.pi/agent/skills"; do
		if [[ -L "$directory" ]]; then
			printf 'Migrate %s to a real directory before running this wrapper.\n' "$directory" >&2
			exit 1
		fi
	done

	mkdir -p "$HOME/.pi/agent/skills"
	for skill in "$root/pi/.pi/agent/skills/"*; do
		[[ -L "$skill" ]] || continue
		case "$(readlink "$skill")" in
		*/.agents/skills/*)
			name=${skill##*/}
			name=${name//./\\.}
			args+=("--ignore=^\\.pi/agent/skills/$name(/|$)")
			;;
		esac
	done
done

exec stow "${args[@]}" "$@"
