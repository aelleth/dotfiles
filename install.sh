#!/bin/sh

script_dir=$(cd $(dirname "$0") && pwd)

binlist="cmake git vim"

for binary in $binlist; do
    if ! which $binary >/dev/null; then
        >&2 echo "error: $binary is not installed"
        exit 1
    fi
done

if [ ! -e ~/.zshrc ]; then
    ln -s $script_dir/zsh/zshrc ~/.zshrc
fi

if [ ! -e ~/.vimrc ]; then
    ln -s $script_dir/vim/vimrc ~/.vimrc
fi
