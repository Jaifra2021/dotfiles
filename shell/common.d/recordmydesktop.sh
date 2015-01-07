screencast() {
    fname=$1
    if [[ -z "$fname" ]]; then
        fname="$(date +'%Y_%m%d-%a-%H%M%S').ogv"
    else
        fname="$fname--$(date +'%Y_%m%d-%a-%H%M%S').ogv"
    fi

    recordmydesktop --on-the-fly-encoding --no-frame -o $fname
}