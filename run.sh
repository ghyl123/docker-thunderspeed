#!/bin/sh

#   Copyright (C) 2016 Deepin, Inc.
#
#   Author:     Li LongYu <lilongyu@linuxdeepin.com>
#               Peng Hao <penghao@linuxdeepin.com>

WINEPREFIX="$HOME/.deepinwine/Deepin-ThunderSpeed"
APPDIR="/opt/deepinwine/apps/Deepin-ThunderSpeed"
APPVER="7.10.35.366deepin17"
APPTAR="files.7z"
PACKAGENAME="deepin.com.thunderspeed"

HelpApp()
{
        echo " Extra Commands:"
        echo " -r/--reset     Reset app to fix errors"
        echo " -e/--remove    Remove deployed app files"
        echo " -h/--help      Show program help info"
}
CallApp()
{
        BASE_DIR="$HOME/.deepinwine/Deepin-ThunderSpeed"
        WINE_CMD="deepin-wine"

        _SetRegistryValue()
        {
        env WINEPREFIX="$BASE_DIR" $WINE_CMD reg ADD "$1" /v "$2" /t $3 /d "$4"
        }

        _SetOverride()
        {
        _SetRegistryValue 'HKCU\Software\Wine\DllOverrides' "$2" REG_SZ "$1"
        }

        env WINEPREFIX="$BASE_DIR" $WINE_CMD "c:\\Program Files\\Thunder Network\\Thunder\\Program\\Thunder.exe"
}
ExtractApp()
{
        mkdir -p "$1"
        7z x "$APPDIR/$APPTAR" -o"$1"
        mv "$1/drive_c/users/@current_user@" "$1/drive_c/users/$USER"
        sed -i "s#@current_user@#$USER#" $1/*.reg
        if [ "$CRACKED"=="true" ]; then
                cp /home/thunderspeed/dll/* "/home/thunderspeed/.deepinwine/Deepin-ThunderSpeed/drive_c/Program Files/Thunder Network/Thunder/Program/"
        fi
        if [ ! -e "/home/thunderspeed/.thunderspeed/Profiles" ]; then
                mv "/home/thunderspeed/.deepinwine/Deepin-ThunderSpeed/drive_c/Program Files/Thunder Network/Thunder/Profiles" /home/thunderspeed/.thunderspeed/
        fi
        rm -rf "/home/thunderspeed/.deepinwine/Deepin-ThunderSpeed/drive_c/Program Files/Thunder Network/Thunder/Profiles"
        ln -s /home/thunderspeed/.thunderspeed/Profiles "/home/thunderspeed/.deepinwine/Deepin-ThunderSpeed/drive_c/Program Files/Thunder Network/Thunder/Profiles"
}
DeployApp()
{
        ExtractApp "$WINEPREFIX"
        echo "$APPVER" > "$WINEPREFIX/PACKAGE_VERSION"
}
RemoveApp()
{
        rm -rf "$WINEPREFIX"
}
ResetApp()
{
        echo "Reset $PACKAGENAME....."
        read -p "*      Are you sure?(Y/N)" ANSWER
        if [ "$ANSWER" = "Y" -o "$ANSWER" = "y" -o -z "$ANSWER" ]; then
                EvacuateApp
                DeployApp
                CallApp
        fi
}
UpdateApp()
{
        if [ -f "$WINEPREFIX/PACKAGE_VERSION" ] && [ "$(cat "$WINEPREFIX/PACKAGE_VERSION")" = "$APPVER" ]; then
                return
        fi
        if [ -d "${WINEPREFIX}.tmpdir" ]; then
                rm -rf "${WINEPREFIX}.tmpdir"
        fi
        ExtractApp "${WINEPREFIX}.tmpdir"
        /opt/deepinwine/tools/updater -s "${WINEPREFIX}.tmpdir" -c "${WINEPREFIX}" -v
        rm -rf "${WINEPREFIX}.tmpdir"
        echo "$APPVER" > "$WINEPREFIX/PACKAGE_VERSION"
}
RunApp()
{
        if [ -d "$WINEPREFIX" ]; then
                UpdateApp
        else
                DeployApp
        fi
        CallApp
}

if [ -z $1 ]; then
        RunApp
        exit 0
fi
case $1 in
        "-r" | "--reset")
                ResetApp
                ;;
        "-e" | "--remove")
                RemoveApp
                ;;
        "-h" | "--help")
                HelpApp
                ;;
        *)
                echo "Invalid option: $1"
                echo "Use -h|--help to get help"
                exit 1
                ;;
esac
exit 0