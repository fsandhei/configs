# NOTE: Make sure that this file is an executable, so
# it can be executed from the parent processes / scripts that require this file.
# This was neccessary for getting lightdm to properly invoke compositor and xmonad.


#!/bin/sh

userresources=$HOME/.Xresources
usermodmap=$HOME/.Xmodmap
sysresources=/etc/X11/xinit/.Xresources
sysmodmap=/etc/X11/xinit/.Xmodmap

# merge in defaults and keymaps

if [ -f $sysresources ]; then
    xrdb -merge $sysresources

fi

if [ -f $sysmodmap ]; then
    xmodmap $sysmodmap
fi

# Just dump information about the connected displays.
xrandr
# Setup screen prior to sourcing the XResources content.
# This is done to make the XResources settings take place properly and be respected by XMonad.
# If done after, these settings might not be respected.
"$HOME"/.local/bin/setup-screen.sh

xsetroot -cursor_name left_ptr

if [ -f "$userresources" ]; then
    xrdb -merge "$userresources"

fi

if [ -f "$usermodmap" ]; then
    xmodmap "$usermodmap"
fi

# start some nice programs

if [ -d /etc/X11/xinit/xinitrc.d ] ; then
 for f in /etc/X11/xinit/xinitrc.d/?*.sh ; do
  [ -x "$f" ] && . "$f"
 done
 unset f
fi

# Start X11 compositor
picom &
# For better handling of mouse handling in X, for example having
# consistent and smooth scrolling.
imwheel &

exec xmonad
