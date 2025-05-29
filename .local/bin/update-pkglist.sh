#! /usr/bin/bash

# Updates the pacman list and makes a commit to the config repository.

config() {
    # config: aliased to /usr/bin/git --git-dir=$HOME/dev/github/configs --work-tree=$HOME
    /usr/bin/git --git-dir=$HOME/dev/github/configs --work-tree=$HOME "$@"
}

print_usage_and_die() {
    prog_name="$(basename $0)"

    echo "$prog_name"
    echo "Updates system package list."
    echo ""
    echo "Updates system package list by querying packages from pacman."
    echo "Usage: $prog_name [-h|--help]"

    exit 0
}

TEMP=$(getopt -o 'h' --long "help" -- "$@")

eval set -- "$TEMP"
unset TEMP

while true; do
    case "$1" in
        '-h' | '--help')
            print_usage_and_die
            ;;
        *)
            shift
            break
            ;;
    esac
done

declare -r TMP_PKGLIST="$HOME/.pkglist.txt.tmp"
declare -r PKGLIST="$HOME/pkglist.txt"

echo "Checking if update is needed..."
pacman -Qqe > "$TMP_PKGLIST"

# check for differences between the temporary package file
# and the current package file by taking the sha256 hash of each file
# and compare them against each other.
declare -r sha256sum_tmp_pkglist=$(sha256sum "$TMP_PKGLIST" | cut -d ' ' -f 1)
declare -r sha256sum_pkglist=$(sha256sum "$PKGLIST" | cut -d ' ' -f 1)

if [ "$sha256sum_tmp_pkglist" != "$sha256sum_pkglist" ]; then
    echo "Updating package list..."
    mv --force "$TMP_PKGLIST" "$PKGLIST"

    declare -r ISO_8601_TIME=$(date +"%Y-%m-%dT%H:%M:%S")

    config diff "$PKGLIST"
    config add "$PKGLIST"
    config commit -m "Update pkglist ($ISO_8601_TIME)"

    echo "Package list updated!"
else
    rm -f "$TMP_PKGLIST"
    echo "No update needed."
fi

