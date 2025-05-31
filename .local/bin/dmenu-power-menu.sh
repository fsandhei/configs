#!/bin/bash
# xmonad-power-menu

# Show menu and get selection
choice=$(echo -e "🔒 Lock Screen\n📤 Logout\n🔄 Reboot\n⏻ Shutdown\n💤 Suspend\n❌ Cancel" | exec dmenu -p 'Power Menu')

# Execute based on choice
case "$choice" in
    *"Lock Screen"*)
        # Use your preferred screen locker
        if command -v betterlockscreen &> /dev/null; then
            betterlockscreen --lock blur
        else
            notify-send "No screen locker found" "Please install betterlockscreen"
        fi
        ;;
    *"Logout"*)
        # Kill all user processes to logout
        pkill -KILL -u "$USER"
        ;;
    *"Reboot"*)
        systemctl reboot
        ;;
    *"Shutdown"*)
        systemctl poweroff
        ;;
    *"Suspend"*)
        systemctl suspend
        ;;
    *"Cancel"*|"")
        # Do nothing
        exit 0
        ;;
esac
