install-home-venv-requirements() {
    if [[ -f /usr/bin/apt-get && -n "$(groups | grep sudo)" ]]; then
        echo -e "\nUpdating apt-get package listing"
        sudo apt-get update || return 1
        sudo apt-get install -y binutils-multiarch gcc g++ python3-dev python3-venv python3-pip python3-setuptools
    elif [[ -f /usr/local/bin/brew ]]; then
        echo -e "\nUpdating homebrew package listing"
        brew update || return 1
        brew install python3
    fi
}

make-home-venv() {
    if [[ "$1" == "clean" ]]; then
        echo -e "\nDeleting ~/venv"
        rm -rf ~/venv
    fi
    if [[ ! -d "$HOME/venv" ]]; then
        install-home-venv-requirements
        cd
        python3 -m venv venv && venv/bin/pip3 install --upgrade pip wheel
        if [[ $(uname) == "Darwin" ]]; then
            venv/bin/pip3 install flake8 grip jupyter awscli httpie asciinema twine pipdeptree rdbtools python-lzf
        else
            venv/bin/pip3 install flake8 grip jupyter awscli httpie asciinema twine pipdeptree
        fi
    else
        echo -e "\nThe ~/venv directory already exists. Use \`make-home-venv clean\` to delete and re-create"
    fi
}

update-home-venv() {
    [[ ! -d "$HOME/venv" ]] && echo "$HOME/venv does not exist" && return 1
    cd
    if [[ $(uname) == "Darwin" ]]; then
        venv/bin/pip3 install --upgrade ipython flake8 grip jupyter awscli httpie asciinema twine pipdeptree rdbtools python-lzf
    else
        venv/bin/pip3 install --upgrade ipython flake8 grip jupyter awscli httpie asciinama twine pipdeptree
    fi
}

home-ipython() {
    PYTHONPATH=$HOME $HOME/venv/bin/ipython "$@"
}

home-site-packages() {
    if [[ -d "$HOME/venv/lib/python3.5/site-packages" ]]; then
        cd "$HOME/venv/lib/python3.5/site-packages"
    elif [[ -d "$HOME/venv/lib/python3.6/site-packages" ]]; then
        cd "$HOME/venv/lib/python3.6/site-packages"
    elif [[ -d "$HOME/venv/lib/python3.7/site-packages" ]]; then
        cd "$HOME/venv/lib/python3.7/site-packages"
    fi

}

venv-site-packages() {
    env_name=$1
    [[ -z "$env_name" ]] && env_name="venv"
    [[ ! -d $env_name ]] && echo "Can't find '$env_name'" && return 1
    if [[ -d "$env_name/lib/python3.5/site-packages" ]]; then
        cd "$env_name/lib/python3.5/site-packages"
    elif [[ -d "$env_name/lib/python3.6/site-packages" ]]; then
        cd "$env_name/lib/python3.6/site-packages"
    elif [[ -d "$env_name/lib/python3.7/site-packages" ]]; then
        cd "$env_name/lib/python3.7/site-packages"
    fi
}

update-home-config() {
    dotfiles && repo-update
    if [[ -n "$BASH_VERSION" ]]; then
        source ~/.bashrc
    elif [[ -n "$ZSH_VERSION" ]]; then
        source ~/.zshrc
    fi
    update-home-venv
    if [[ ! -d "$HOME/.beu" ]]; then
        curl -o- https://raw.githubusercontent.com/kenjyco/beu/master/install.sh | bash
    elif [[ "$1" == "reinstall" ]]; then
        beu-reinstall
    else
        beu-update
    fi
}

get-version-from-setup() {
    oldpwd=$(pwd)
    repo_path=$(repo-path $(pwd))
    [[ -z "$repo_path" ]] && return 1
    cd "$repo_path"
    grep download_url setup.py 2>/dev/null | perl -pe 's/^.*(v[\d\.]+).*/$1/'
    cd "$oldpwd"
}

test-install-in-tmp() {
    if [[ ! -f venv/bin/python3 ]]; then
        echo "Could not find venv/bin/python3 in $(pwd)"
        return 1
    fi
    do_stash=
    [[ "$1" == 'stash' ]] && do_stash="yes"
    oldpwd=$(pwd)
    project_name=$(basename $oldpwd)
    version=$(get-version-from-setup)
    if [[ -z "$version" ]]; then
        echo "Could not determine version from 'download_url' in 'setup.py'"
        version='unknown-version'
    fi
    tmp_dir=/tmp/$project_name--$version

    mkdir -pv $tmp_dir
    [[ -n "$do_stash" ]] && stashstatus=$(git stash)
    clean-py >/dev/null
    venv/bin/python3 setup.py bdist_wheel || return 1
    cp -av dist/* $tmp_dir || return 1
    cd $tmp_dir || return 1
    rm -rf venv
    python3 -m venv venv && venv/bin/pip3 install --upgrade pip wheel
    venv/bin/pip3 install *.whl ipython pdbpp
    echo -e "\n$(pwd)\n"
    PYTHONPATH="$tmp_dir" venv/bin/ipython
    cd "$oldpwd"
    if [[ -n "$do_stash" &&  $stashstatus != "No local changes to save" ]]; then
        git stash pop
    fi
}

bump-setup-version() {
    repo_path=$(repo-path $(pwd))
    if [[ -z "$repo_path" ]]; then
        echo "Not currently in a git repo"
        return 1
    fi
    oldpwd=$(pwd)
    cd "$repo_path"
    version=$(get-version-from-setup)
    if [[ -z "$version" ]]; then
        echo "Could not determine version from 'download_url' in 'setup.py'"
        cd "$oldpwd"
        return 1
    elif [[ "${version:0:1}" = 'v' ]]; then
        version=$(echo $version | cut -c 2-)
    fi
    incr_type="$1"
    if [[ -z "$incr_type" ]]; then
        incr_type='0.0.1'
    fi
    _major=$(echo $version | cut -d. -f1)
    _minor=$(echo $version | cut -d. -f2)
    _micro=$(echo $version | cut -d. -f3)
    if [[ "$incr_type" = '1.0.0' ]]; then
        _major=$((_major+1))
        _minor=0
        _micro=0
    elif [[ "$incr_type" = '0.1.0' ]]; then
        _minor=$((_minor+1))
        _micro=0
    elif [[ "$incr_type" = '0.0.1' ]]; then
        _micro=$((_micro+1))
    else
        echo "incr_type must be '1.0.0', '0.1.0', or '0.0.1', not $incr_type"
        return 1
    fi
    new_version="$_major.$_minor.$_micro"
    if [[ $(uname) == "Darwin" ]]; then
        sed -i "" "s/${version}/${new_version}/" setup.py
    else
        sed -i "s/${version}/${new_version}/" setup.py
    fi
    git add setup.py
    git commit -m "Bump to v$new_version"
    echo -e "\nNot pushed\n"
    unpushed-commits
}

tag-and-release() {
    if [[ ! -s ~/.pypirc ]]; then
        echo "Could not find ~/.pypirc file"
        return 1
    fi
    if [[ ! -f venv/bin/python3 ]]; then
        echo "Could not find venv/bin/python3 in $(pwd)"
        return 1
    fi
    repo_path=$(repo-path $(pwd))
    if [[ -z "$repo_path" ]]; then
        echo "Not currently in a git repo"
        return 1
    fi
    oldpwd=$(pwd)
    cd "$repo_path"
    version=$(get-version-from-setup)
    if [[ -z "$version" ]]; then
        echo "Could not determine version from 'download_url' in 'setup.py'"
        cd "$oldpwd"
        return 1
    elif [[ "$version" = $(lasttag) ]]; then
        echo "Most recent git tag matches 'download_url' in 'setup.py'"
        cd "$oldpwd"
        return 1
    fi

    cmd="git tag -a $version"
    echo -e "lasttag was $(lasttag)\ncmd would be: $cmd"
    unset yn
    if [[ -n "$BASH_VERSION" ]]; then
        read -p "Continue? [y/n] " yn
    elif [[ -n "$ZSH_VERSION" ]]; then
        vared -p "Continue? [y/n] " -c yn
    fi
    if [[ "$yn" =~ [yY].* ]]; then
        eval "$cmd"
    else
        return 1
    fi
    [[ $? != 0 ]] && return 1
    git push --tags

    stashstatus=$(git stash)
    clean-py >/dev/null
    venv/bin/python3 setup.py bdist_wheel || return 1
    twine upload dist/*
    if [[ $stashstatus != "No local changes to save" ]]; then
        git stash pop
    fi
    cd "$oldpwd"
}

get-dependency-tree() {
    [[ -z "$1" ]] && return 1
    python3 -m venv tmp_env && tmp_env/bin/pip install pipdeptree "$@" &&
    tmp_env/bin/pipdeptree > dep-tree-output.txt && less dep-tree-output.txt
}

grip() {
    PYTHONPATH=$HOME $HOME/venv/bin/grip "$@"
}

flake8() {
    PYTHONPATH=$HOME $HOME/venv/bin/flake8 "$@"
}

flakeit() {
    flake8 --exclude='venv/*' . |
    egrep -v '(line too long|import not at top of file|imported but unused|do not assign a lambda)'
}

jupyter() {
    PYTHONPATH=$HOME $HOME/venv/bin/jupyter "$@"
}

aws() {
    PYTHONPATH=$HOME $HOME/venv/bin/aws "$@"
}

http() {
    PYTHONPATH=$HOME $HOME/venv/bin/http "$@"
}

twine() {
    PYTHONPATH=$HOME $HOME/venv/bin/twine "$@"
}

rdb() {
    if [[ $(uname) == "Darwin" ]]; then
        PYTHONPATH=$HOME $HOME/venv/bin/rdb "$@"
    fi
}

asciinema() {
    PYTHONPATH=$HOME $HOME/venv/bin/asciinema "$@"
}

pipdeptree() {
    PYTHONPATH=$HOME $HOME/venv/bin/pipdeptree "$@"
}

#----------------------------------------------------------------------#
# Old shell funcs and aliases: makeenv, activate, Deactivate, aipy, try-it
#
# # Create a Python virtual environment and an optional Node virtual environment.
# makeenv() {
#     envpy="$1"
#     envjs="$2"
#     if [[ "$envpy" == "$envjs" && -n "$envjs" ]]; then
#         echo "Abort: node env cannot be the same as python env!"
#         return 1
#     fi
#     if [[ -z "$envpy" ]]; then
#         envpy="env"
#     fi
#
#     # Create python environment and install requirements.txt (as well as
#     # ipython and ipdb).
#     virtualenv --no-site-packages ${envpy}
#     if [[ $? -ne 0 ]]; then
#         echo "Abort: Something went wrong creating python env!"
#         rm -rf $envpy 2>/dev/null
#         return 1
#     fi
#     ${envpy}/bin/pip install ipython ipdb pytest git+git://github.com/mverteuil/pytest-ipdb.git
#     [[ -f requirements.txt ]] && ${envpy}/bin/pip install -r requirements.txt
#
#     # Create node environment (if specified) and activate environment(s).
#     if [[ -n "$envjs" ]]; then
#         # Install nodeenv to the python virtual environment.
#         ${envpy}/bin/pip install nodeenv
#
#         # Create node environment and install whatever is in package.json
#         # (if it exists).
#         if [[ 0 -eq $? ]]; then
#             echo "Creating node.js environment. This will take a while."
#             ${envpy}/bin/nodeenv $envjs
#             [[ -f package.json ]] && ${envjs}/bin/npm install
#         else
#             echo "Abort: Something went wrong installing nodeenv package!"
#             rm -rf $envpy $envjs 2>/dev/null
#             return 1
#         fi
#         activate $envpy $envjs
#     else
#         activate $envpy
#     fi
# }
#
# # Deactivate Python virtual environment (including an internal Node environment)
# alias Deactivate="deactivate_node 2>/dev/null; deactivate 2>/dev/null"
#
# # Activate Python virtual environment (as well as an optional Node environment).
# export VIRTUAL_ENV_DISABLE_PROMPT=1
# export NODE_VIRTUAL_ENV_DISABLE_PROMPT=1
# activate() {
#     envpy="$1"
#     envjs="$2"
#     if [[ "$envpy" == "$envjs" && -n "$envjs" ]]; then
#         echo "Abort: node env cannot be the same as python env!"
#         return 1
#     fi
#
#     if [[ -z "$envpy" ]]; then
#         # Check to see if envpy should be 'env', 'venv', or '.'
#         [[ -f "env/bin/activate" ]] && envpy="env"
#         [[ -f "venv/bin/activate" ]] && envpy="venv"
#         [[ -f "./bin/activate" ]] && envpy="."
#
#         if [[ -z "$envpy" ]]; then
#             echo "Abort: Could not determine environment to activate!"
#             return 1
#         fi
#     fi
#
#     if [[ ! -f "${envpy}/bin/activate" ]]; then
#         echo "Abort: No activation script at ${envpy}/bin/activate"
#         return 1
#     fi
#
#     # Activate python environment.
#     source "${envpy}/bin/activate"
#
#     # Activate node environment, if specified.
#     if [[ -n "$envjs" ]]; then
#         if [[ ! -f "${envjs}/bin/activate" ]]; then
#             Deactivate
#             echo "Abort: No activation script at ${envjs}/bin/activate"
#             return 1
#         else
#             source "${envjs}/bin/activate"
#         fi
#     fi
#     which python3
#     which pip3
# }
#
# alias aipy='activate && ipython'
#
# try-it() {
#     script=
#     if [ -f "$1" ]; then
#         script=$(basename "$1")
#         dname=$(dirname "$1")
#         cd "$dname"
#         shift
#     elif [ -d "$1" ]; then
#         cd "$1"
#         shift
#     fi
#
#     # If this is not an autoenv directory that automatically starts the python
#     # virtualenv when we cd to it, manually activate the virtualenv.
#     if [ ! -s ".env" ]; then
#         # Activate the python environment (or create it if it doesn't exist).
#         activate >/dev/null 2>&1 || makeenv
#     else
#         echo -e "\nNeed to confirm that autoenv worked...\n"
#         sleep 2
#     fi
#
#     # If a script name was passed in, or if there is only one .py file in the
#     # directory, run it and deactivate the virtual environment.
#     if [ -n "$script" ]; then
#         python "$script" $@
#         Deactivate
#         cd $OLDPWD
#     elif [ $(ls -1 *.py | wc -l) -eq 1 ]; then
#         # If there is exactly 1 python script in this directory, run it
#         python *.py $@
#         Deactivate
#         cd $OLDPWD
#     else
#         echo -e "\nBe sure to issue the 'Deactivate' command when finished.\n"
#     fi
# }
