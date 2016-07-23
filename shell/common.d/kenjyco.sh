# Don't set anything in this file if `~/.kenjyco_path` does not exist
[[ -f $HOME/.kenjyco_path ]] && export PYTHONPATH="$(cat $HOME/.kenjyco_path):$PYTHONPATH" || return 1

KENJYCO_PATH="$(cat $HOME/.kenjyco_path)"

kenjyco() {
    cd $KENJYCO_PATH
}

k() {
    ${KENJYCO_PATH}/venv/bin/python -m kenjyco
}

v() {
    oldpwd=$(pwd)
    cdd ~/vidsearch
    ${KENJYCO_PATH}/venv/bin/python ${KENJYCO_PATH}/kenjyco/misc/vidsearch.py $@
    cd "$oldpwd"
}

websearch() {
    oldpwd=$(pwd)
    cdd ~/websearch
    ${KENJYCO_PATH}/venv/bin/python ${KENJYCO_PATH}/kenjyco/misc/websearch.py $@
    cd "$oldpwd"
}

listen() {
    ${KENJYCO_PATH}/venv/bin/python ${KENJYCO_PATH}/kenjyco/misc/listen.py $@
}

download() {
    ${KENJYCO_PATH}/venv/bin/python ${KENJYCO_PATH}/kenjyco/misc/download.py $@
}

looper() {
    ${KENJYCO_PATH}/venv/bin/python ${KENJYCO_PATH}/kenjyco/misc/looper.py $@
}

myvlc() {
    ${KENJYCO_PATH}/venv/bin/python ${KENJYCO_PATH}/kenjyco/misc/vlc.py $@
}

make-home-venv() {
    if [[ ! -d "$HOME/venv" ]]; then
        cd
        python3 -m venv venv && python3 -m venv --system-site-packages venv && venv/bin/pip3 install wheel
		venv/bin/pip3 install -r ${KENJYCO_PATH}/requirements.txt --upgrade
        venv/bin/pip3 install flake8 grip jupyter
    fi
}
make-home-venv

grip() {
    $HOME/venv/bin/grip $@
}

flake8() {
    $HOME/venv/bin/flake8 $@
}

jupyter() {
    $HOME/venv/bin/jupyter $@
}

flakeit() {
    flake8 --exclude='venv/*' . |
    egrep -v '(line too long|import not at top of file|imported but unused|do not assign a lambda)'
}
