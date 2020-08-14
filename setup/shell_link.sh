#!/usr/bin/env bash
#  vim:ts=4:sts=4:sw=4:et
#
#  Author: Hari Sekhon
#  Date: 2019-09-18 23:21:50 +0100 (Wed, 18 Sep 2019)
#
#  https://github.com/harisekhon/bash-tools
#
#  License: see accompanying Hari Sekhon LICENSE file
#
#  If you're using my code you're welcome to connect with me on LinkedIn and optionally send me feedback to help steer this or other code I publish
#
#  https://www.linkedin.com/in/harisekhon
#

# Checks if .bashrc and .bash_profile are sourced, otherwise injects source lines in to the $HOME directory equivalents

set -euo pipefail
[ -n "${DEBUG:-}" ] && set -x
srcdir="$(cd "$(dirname "${BASH_SOURCE[0]}")"/.. && pwd)"

conf_files="$(sed 's/#.*//; /^[[:space:]]*$/d' "$srcdir/setup/files.txt")"

setup_file(){
    local filename="$1"
    if grep -Eq "^[[:space:]]*(source|\\.)[[:space:]]+$srcdir/$filename" ~/"$filename" 2>/dev/null; then
        echo "$filename already sourced in ~/$filename"
    else
        echo "injecting into ~/$filename: source $srcdir/$filename"
        echo "source $srcdir/$filename" >> ~/"$filename"
    fi
}

setup_file .bashrc
setup_file .bash_profile

setup_file .zshrc
setup_file .zprofile
setup_file .zshenv
setup_file .zlogin
setup_file .zlogout

echo
echo "symlinking dot files to \$HOME directory: $HOME"
echo

opts=""
if [ -n "${FORCE:-}" ]; then
    opts="-f"
fi

for filename in $conf_files; do
    if [[ "$filename" =~ / ]]; then
        dirname="${filename%/*}"
        filename="${filename##*/}"
        mkdir -pv ~/"$dirname"
        # want opt expansion
        # shellcheck disable=SC2086
        ln -sv $opts "$PWD/$dirname/$filename" ~/"$dirname"/ || :
    else
        # want opt expansion
        # shellcheck disable=SC2086
        ln -sv $opts "$PWD/$filename" ~ || :
    fi
done

# want opt expansion
# shellcheck disable=SC2086
ln -sv $opts ~/.gitignore ~/.gitignore_global || :

if [[ "${USER:-}" =~ harisekhon|hsekhon ]]; then
    ln -sv "$PWD/.gitconfig.local" ~ || :
fi
