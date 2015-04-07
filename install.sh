#!/bin/sh

script_dir=$(cd $(dirname "$0") && pwd)

git_submodule_needs_init() {
    res=`git submodule status $1 | awk '{ print substr($0, 0, 1) }'`
    if [ "$res" = "-" ]; then
        return 0
    else
        return 1
    fi
}

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

if [ ! -e ~/.zlogin ]; then
    ln -s $script_dir/zsh/zlogin ~/.zlogin
fi

if [ ! -e ~/.vimrc ]; then
    ln -s $script_dir/vim/vimrc ~/.vimrc
fi

if [ ! -e ~/.tmux.conf ]; then
    ln -s $script_dir/tmux/tmux.conf ~/.tmux.conf
fi

if [ ! -d ~/.vim/bundle/Vundle.vim ] || \
    ! git rev-parse --git-dir ~/.vim/bundle/Vundle.vim >/dev/null 2>&1; then
    mkdir -p ~/.vim/bundle
    git clone https://github.com/gmarik/Vundle.vim.git ~/.vim/bundle/Vundle.vim
    echo "Installing Vim plugins..."
    vim -e +PluginInstall +qall > /dev/null 2>&1

    # Install YouCompleteMe support libs with C-family semantic completion.
    CDEFINES="-DUSE_CLANG_COMPLETER=ON"

    # On OSX, if you have Homebrew Python installed, YCM will be linked against
    # it, but the Homebrew version of Vim is linked against the system Python.
    # Segfaults and hilarity ensue.
    #
    # In order to restore chaos in this madness, we explicitly point clang to
    # the system Python headers and shared libraries.
    osname=`uname -o`
    if [ $osname == "Darwin" ]; then
        CDEFINES="$CDEFINES -DPYTHON_LIBRARY=/System/Library/Frameworks/Python.framework/Versions/2.7/lib/libpython2.7.dylib"
        CDEFINES="$CDEFINES -DPYTHON_INCLUDE_DIR=/System/Library/Frameworks/Python.framework/Versions/2.7/Headers"
    fi

    ycm_build_dir=`mktemp -d /tmp/ycm_build.XXXXXX`
    cd $ycm_build_dir
    cmake -G "Unix Makefiles" $CDEFINES . \
        ~/.vim/bundle/YouCompleteMe/third_party/ycmd/cpp
    make ycm_support_libs
    cd $script_dir
    rm -r $ycm_build_dir
fi

if [ ! -d ~/.vim/plugin ]; then
    ln -s $script_dir/vim/plugin ~/.vim/plugin
fi

if git_submodule_needs_init "dircolors-solarized"; then
    git submodule init dircolors-solarized
    git submodule update dircolors-solarized
fi

if [ ! -e ~/.dircolors ]; then
    ln -s $script_dir/dircolors-solarized/dircolors.256dark ~/.dircolors
fi
