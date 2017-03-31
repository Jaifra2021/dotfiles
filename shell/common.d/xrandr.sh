fix-monitors-x200-below-1920() {
    xrandr --output VGA1 --mode 1920x1080 --primary
    xrandr --output LVDS1 --mode 1280x800 --below VGA1
}

fix-monitors-t530-below-1920() {
    xrandr --output VGA2 --mode 1920x1080 --primary
    xrandr --output LVDS2 --mode 1920x1080 --below VGA2
}

fix-monitors-t420-below-1920() {
    xrandr --output VGA1 --mode 1920x1080 --primary
    xrandr --output LVDS1 --mode 1366x768 --below VGA1
}

fix-monitors-x200-portrait-right-1920() {
    xrandr --output VGA1 --mode 1920x1080 --primary
    xrandr --output LVDS1 --mode 1280x800 --rotate left --right-of VGA1
}

fix-monitors-tv-vga() {
    xrandr --output LVDS1 --off
    xrandr --output VGA1 --mode 1920x1080
    xrandr --output VGA1 --primary
}

fix-monitors-tv-hdmi() {
    xrandr --output LVDS1 --off
    xrandr --output HDMI1 --mode 1920x1080
    xrandr --output HDMI1 --primary
}

fix-monitors-edge-tv() {
    xrandr --output eDP1 --off
    xrandr --output HDMI1 --mode 1920x1080
    xrandr --output HDMI1 --primary
}
