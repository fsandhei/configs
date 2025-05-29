# NOTE: Make sure that this file is an executable, so
# it can be executed from the parent processes / scripts that require this file.
# This was necessary for getting lightdm to properly invoke compositor and xmonad.
#
# Note that there exists an symlink .xsession that points to this file.
# This is done for the purpose of the lightdm display manager. lightdm executes
# .xsession at a successful login.


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

# By default, the X shaped cursor appears in those window managers
# that don't set a default cursor.
# We therefore set the cursor, just in case.
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

exec xmonad
