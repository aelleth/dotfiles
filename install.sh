#!/bin/sh

script_dir=$(cd "$(dirname "$0")" && pwd)

git_submodule_needs_init() {
    res=$(git submodule status "$1" | awk '{ print substr($0, 0, 1) }')
    if [ "$res" = "-" ]; then
        return 0
    else
        return 1
    fi
}

binlist="cmake git vim ruby"

for binary in $binlist; do
    if ! which "$binary" >/dev/null; then
        >&2 echo "error: $binary is not installed"
        exit 1
    fi
done

if [ ! -e ~/.zshrc ]; then
    ln -s "$script_dir/zsh/zshrc" ~/.zshrc
fi

if [ ! -e ~/.zlogin ]; then
    ln -s "$script_dir/zsh/zlogin" ~/.zlogin
fi

if [ ! -e ~/.vimrc ]; then
    ln -s "$script_dir/vim/vimrc" ~/.vimrc
fi

if [ ! -e ~/.tmux.conf ]; then
    ln -s "$script_dir/tmux/tmux.conf" ~/.tmux.conf
fi

if [ ! -d ~/.vim/bundle/Vundle.vim ] || \
    ! git rev-parse --git-dir ~/.vim/bundle/Vundle.vim >/dev/null 2>&1; then
    mkdir -p ~/.vim/bundle
    git clone https://github.com/gmarik/Vundle.vim.git ~/.vim/bundle/Vundle.vim
    echo "Installing Vim plugins..."
    vim -e +PluginInstall +qall > /dev/null 2>&1

    cd ~/.vim/bundle/YouCompleteMe
    ./install.py --clang-completer --gocode-completer  --omnisharp-completer --tern-completer --racer-completer
    cd "$script_dir"

    # Command-T compiled portion
    cd ~/.vim/bundle/Command-T/ruby/command-t
    ruby extconf.rb
    make
    cd "$script_dir"
fi

if [ ! -d ~/.vim/plugin ]; then
    ln -s "$script_dir/vim/plugin" ~/.vim/plugin
fi

if git_submodule_needs_init "dircolors-solarized"; then
    git submodule init dircolors-solarized
    git submodule update dircolors-solarized
fi

if [ ! -e ~/.dircolors ]; then
    ln -sf "$script_dir/dircolors-solarized/dircolors.256dark" ~/.dircolors
fi
