#!/bin/sh

script_dir=$(cd $(dirname "$0") && pwd)

if [ ! -e ~/.zshrc ]; then
    ln -s $script_dir/zsh/zshrc ~/.zshrc
fi

if [ ! -e ~/.vimrc ]; then
    ln -s $script_dir/vim/vimrc ~/.vimrc
fi
