# Deactivate Python virtual environment (including an internal Node environment)
alias Deactivate="deactivate_node 2>/dev/null; deactivate 2>/dev/null"

# Activate Python virtual environment (as well as an optional Node environment).
export VIRTUAL_ENV_DISABLE_PROMPT=1
export NODE_VIRTUAL_ENV_DISABLE_PROMPT=1
activate() {
    envpy="$1"
    envjs="$2"
    if [[ "$envpy" == "$envjs" && ! -z "$envjs" ]]; then
        echo "Abort: node env cannot be the same as python env!"
        return 1
    fi

    if [[ -z "$envpy" ]]; then
        # Check to see if envpy should be 'env', 'venv', or '.'
        [[ -f "env/bin/activate" ]] && envpy="env"
        [[ -f "venv/bin/activate" ]] && envpy="venv"
        [[ -f "./bin/activate" ]] && envpy="."

        if [[ -z "$envpy" ]]; then
            echo "Abort: Could not determine environment to activate!"
            return 1
        fi
    fi

    if [[ ! -f "${envpy}/bin/activate" ]]; then
        echo "Abort: No activation script at ${envpy}/bin/activate"
        return 1
    fi

    # Activate python environment.
    source "${envpy}/bin/activate"

    # Activate node environment, if specified.
    if [[ ! -z "$envjs" ]]; then
        if [[ ! -f "${envjs}/bin/activate" ]]; then
            Deactivate
            echo "Abort: No activation script at ${envjs}/bin/activate"
            return 1
        else
            source "${envjs}/bin/activate"
        fi
    fi
    which python
    which pip
}

# Create a Python virtual environment and an optional Node virtual environment.
makeenv() {
    envpy="$1"
    envjs="$2"
    if [[ "$envpy" == "$envjs" && ! -z "$envjs" ]]; then
        echo "Abort: node env cannot be the same as python env!"
        return 1
    fi
    if [[ -z "$envpy" ]]; then
        envpy="env"
    fi

    # Create python environment and install requirements.txt (as well as
    # ipython and ipdb).
    virtualenv --no-site-packages ${envpy}
    if [[ $? -ne 0 ]]; then
        echo "Abort: Something went wrong creating python env!"
        rm -rf $envpy 2>/dev/null
        return 1
    fi
    ${envpy}/bin/pip install ipython ipdb
    [[ -f requirements.txt ]] && ${envpy}/bin/pip install -r requirements.txt

    # Create node environment (if specified) and activate environment(s).
    if [[ ! -z "$envjs" ]]; then
        # Install nodeenv to the python virtual environment.
        ${envpy}/bin/pip install nodeenv

        # Create node environment and install whatever is in package.json
        # (if it exists).
        if [[ 0 -eq $? ]]; then
            echo "Creating node.js environment. This will take a while."
            ${envpy}/bin/nodeenv $envjs
            [[ -f package.json ]] && ${envjs}/bin/npm install
        else
            echo "Abort: Something went wrong installing nodeenv package!"
            rm -rf $envpy $envjs 2>/dev/null
            return 1
        fi
        activate $envpy $envjs
    else
        activate $envpy
    fi
}

alias aipy='activate && ipython'

try-it() {
    script=
    if [ -f "$1" ]; then
        script=`basename "$1"`
        dname=`dirname "$1"`
        cd "$dname"
        shift
    elif [ -d "$1" ]; then
        cd "$1"
        shift
    fi

    # If this is not an autoenv directory that automatically starts the python
    # virtualenv when we cd to it, manually activate the virtualenv.
    if [ ! -s ".env" ]; then
        # Activate the python environment (or create it if it doesn't exist).
        activate >/dev/null 2>&1 || makeenv
    else
        echo -e "\nNeed to confirm that autoenv worked...\n"
        sleep 2
    fi

    # If a script name was passed in, or if there is only one .py file in the
    # directory, run it and deactivate the virtual environment.
    if [ ! -z "$script" ]; then
        python "$script" $@
        Deactivate
        cd $OLDPWD
    elif [ $(ls -1 *.py | wc -l) -eq 1 ]; then
        # If there is exactly 1 python script in this directory, run it
        python *.py $@
        Deactivate
        cd $OLDPWD
    else
        echo -e "\nBe sure to issue the 'Deactivate' command when finished.\n"
    fi
}