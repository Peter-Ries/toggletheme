#!/bin/bash


# ---------------------------------------------------------
#
# toggletheme
#   - switch wallpaper, colorscheme, ... between dark / light
#
#   - works best with default Breeze theme "following current color scheme"
#   - window shadow color may not work with other window decorations than Breeze (breezerc)
#   - script does not check if wallpaper, vs-code theme, konsole profile exist
#     so please check init section and switchVSCode() function
#
#   - you only need:
#       - wallpaper/s for each theme
#       - KDE colorschemes used here KritaDarkOrange, FlatRemixBlueDarkest
#       - VS-Code themes used here: Simple Dark, Just Black
#       - Konsole profiles for your needs
#
# ---------------------------------------------------------


# #########################################################
# init - set variables -
# #########################################################

# read config
CONFIG_FILE=$HOME/.config/toggletheme.cfg
CURRENT_THEME=$(kreadconfig5 --file $CONFIG_FILE --group General --key CurrentTheme)

# RGB colors for window border shadow
RGB_BLACK="0,0,0" #000000
RGB_BLUE="61,174,233" #3daee9
RGB_BLUE_BLACK="39,119,255" #2777ff
RGB_ORANGE="246,116,0" #ffa200

# HEX colors for accent
HEX_BLUE="#3daee9"
HEX_BLUE_BLACK="#2777ff"
HEX_ORANGE="#ffa200"

# picture for wallpaper all monitors and lockscreen
SWITCH_WALLPAPER="y"
LIGHT_WALLPAPER="$HOME/Bilder/Wallpapers/ventura.jpg"
DARK_WALLPAPER="$HOME/Bilder/Wallpapers/ventura-dark.jpg"
DARKER_WALLPAPER="$HOME/Bilder/Wallpapers/ventura-dark.jpg"
BLACK_WALLPAPER="$HOME/Bilder/Wallpapers/ios-blue-background.jpg"

# desktoptheme - aka Plasma Style
# SHOULD ALWAYS BE SET TO "default" and should be set initially for script to work!
#   default         <<<--- we need this one always to follow colorscheme
#   breeze-dark
#   breeze-light
SWITCH_DESKTOPTHEME="y"
LIGHT_DESKTOPTHEME="default"
DARK_DESKTOPTHEME="default"
DARKER_DESKTOPTHEME="default"
BLACK_DESKTOPTHEME="default"

# look-and-feel - a.k.a. Global Design
#   org.kde.breeze.desktop
#   org.kde.breezedark.desktop
#   org.kde.breezetwilight.desktop  <<<--- as an alternative for light
SWITCH_LOOKANDFEEL="y"
LIGHT_LOOKANDFEEL="org.kde.breeze.desktop"
DARK_LOOKANDFEEL="org.kde.breezedark.desktop"
DARKER_LOOKANDFEEL="org.kde.breezedark.desktop"
BLACK_LOOKANDFEEL="org.kde.breezedark.desktop"
# disable or enable default breeze splashscreen
ENABLE_SPLASHSCREEN="n"
# overwrite look-and-feel task-switcher
TASKSWITCHER_OVERWRITE="y"
TASKSWITCHER_STYLE="thumbnail_grid"

# GTK Theme
SWITCH_GTKTHEME="y"
LIGHT_GTKTHEME="Breeze"
DARK_GTKTHEME="Breeze"
DARKER_GTKTHEME="Breeze"
BLACK_GTKTHEME="Breeze"

# colorscheme
SWITCH_COLORSCHEME="y"
LIGHT_COLORSCHEME="BreezeClassic"
DARK_COLORSCHEME="BreezeClassicDarkInactiveDimmed"
DARKER_COLORSCHEME="KritaDarkOrange"
BLACK_COLORSCHEME="FlatRemixBlueDarkest"
#
# SWITCH_ACCENTCOLOR:
#   t - use theme color
#   w - from wallpaper main color
#   c - color (uses values you set in *_ACCENTCOLOR)
SWITCH_ACCENTCOLOR="t"
LIGHT_ACCENTCOLOR=$HEX_BLUE
DARK_ACCENTCOLOR=$HEX_BLUE
DARKER_ACCENTCOLOR=$HEX_ORANGE
BLACK_ACCENTCOLOR=$HEX_BLUE_BLACK

# window border shadow color
SWITCH_SHADOW="y"
LIGHT_SHADOW=$RGB_BLACK
DARK_SHADOW=$RGB_ORANGE
DARKER_SHADOW=$RGB_ORANGE
BLACK_SHADOW=$RGB_BLUE_BLACK

# icon set
SWITCH_ICONS="y"
LIGHT_ICONS="breeze"
DARK_ICONS="breeze-dark"
DARKER_ICONS="breeze-dark"
BLACK_ICONS="breeze-dark"

# konsole colors
SWITCH_KONSOLE="y"
# create corresponding konsole profiles. put name without extension here.
LIGHT_KONSOLE="BlackOnWhite"
DARK_KONSOLE="Breeze"
DARKER_KONSOLE="Breeze"
BLACK_KONSOLE="BlackBlue"

# vs-code colortheme
SWITCH_VSCODE="y"
VSCODE_LIGHTTHEME="Default Light+"
VSCODE_DARKTHEME="Simple Dark"
VSCODE_DARKERTHEME="Simple Dark"
VSCODE_BLACKTHEME="Just Black"


# #########################################################
# functions
# #########################################################

switchWallpaper() {
    if [[ $SWITCH_WALLPAPER == "y" ]] ; then
        #
        # switch wallpaper
        plasma-apply-wallpaperimage $1
        #
        # switch lockscreen wallpaper
        kwriteconfig5 --file kscreenlockerrc --group Greeter --group Wallpaper --group org.kde.image --group General --key Image "file://$1"
    fi
}

switchDesktoptheme() {
    if [[ $SWITCH_DESKTOPTHEME == "y" ]] ; then
        plasma-apply-desktoptheme $1
    fi
}

switchLookandfeel() {
    if [[ $SWITCH_LOOKANDFEEL == "y" ]] ; then
        plasma-apply-lookandfeel --apply $1

        # splashscreen none or breeze?
        if [[ $ENABLE_SPLASHSCREEN == "y" ]] ; then
            # breeze is default and has an empty ksplashrc - so delete entries
            kwriteconfig5 --file ksplashrc --group KSplash --key Engine --delete
            kwriteconfig5 --file ksplashrc --group KSplash --key Theme --delete
        else
            kwriteconfig5 --file ksplashrc --group KSplash --key Engine None
            kwriteconfig5 --file ksplashrc --group KSplash --key Theme None
        fi

        # use different taskswitcher?
        if [[ $TASKSWITCHER_OVERWRITE == "y" ]] ; then
            kwriteconfig5 --file kwinrc --group TabBox --key LayoutName $TASKSWITCHER_STYLE
        fi
    fi
}

switchGtktheme() {
    if [[ $SWITCH_GTKTHEME == "y" ]] ; then
        qdbus org.kde.GtkConfig /GtkConfig org.kde.GtkConfig.setGtkTheme $1
    fi
}

switchColorscheme() {
    if [[ $SWITCH_COLORSCHEME == "y" ]] ; then
        plasma-apply-colorscheme $1
    fi

    #
    # switch accentcolor only of switch is "y" AND accentcolor is set otherwise use theme accent color
    # NOT WORKING YET...
    #     if [[ $SWITCH_ACCENTCOLOR == "c" ]] && [[ $2 != "" ]] ; then
    #         plasma-apply-colorscheme --accent-color $2
    #         kwriteconfig5 --file kdeglobals --group General --key accentColorFromWallpaper "false"
    #     fi
    #     if [[ $SWITCH_ACCENTCOLOR == "w" ]] ; then
    #         kwriteconfig5 --file kdeglobals --group General --key AccentColor --delete
    #         kwriteconfig5 --file kdeglobals --group General --key accentColorFromWallpaper "true"
    #     fi
    #     if [[ $SWITCH_ACCENTCOLOR == "t" ]] ; then
    #         kwriteconfig5 --file kdeglobals --group General --key AccentColor --delete
    #         kwriteconfig5 --file kdeglobals --group General --key accentColorFromWallpaper "false"
    #     fi
}

switchShadow() {
    if [[ $SWITCH_SHADOW == "y" ]] ; then
        #
        # set ShadowColor (R,G,B) in $HOME/.config/breezerc
        kwriteconfig5 --file breezerc --group Common --key ShadowColor $1
    fi
}

switchIcons() {
    if [[ $SWITCH_ICONS == "y" ]] ; then
        /usr/lib/plasma-changeicons $1
    fi
}

switchKonsole () {
    if [[ $SWITCH_KONSOLE == "y" ]] ; then
        #
        # define Breeze.profile and BlackOnWhite.profile profiles first for konsole!
        # set default profile for new instances
        kwriteconfig5 --file konsolerc --group "Desktop Entry" --key "DefaultProfile" $1".profile"
        #
        # apply to all running instances
        IFS=" "
        PIDS=$(pidof konsole)
        for PID in $PIDS; do
            qdbus org.kde.konsole-$PID /Sessions/1 org.kde.konsole.Session.setProfile $1
        done
    fi
}

switchVSCode () {
    if [[ $SWITCH_VSCODE == "y" ]] ; then
        #
        # modify settings directly with sed in ~/.config/Code/User/settings.json
        sed -i -e "s/\"workbench.colorTheme.*$/\"workbench.colorTheme\": \"$NEW_VSCODETHEME\",/" ~/.config/Code/User/settings.json
    fi
}




# #########################################################
# main
# #########################################################

if [[ $1 == "" ]] ; then
    #
    # no parameter - only toggle light/dark
    case $CURRENT_THEME in
        light)
            NEW_THEME="dark"
            ;;
        *)
            NEW_THEME="light"
            ;;
    esac
else
    #
    # parameter -> evaluate
    case $1 in
        light | dark | darker | black )
            NEW_THEME=$1
            ;;
        *)
            echo Only light, dark, darker, black allowed as parameter.
            exit 1
            ;;
    esac
fi

case $NEW_THEME in
    light)
        NEW_WALLPAPER=$LIGHT_WALLPAPER
        NEW_DESKTOPTHEME=$LIGHT_DESKTOPTHEME
        NEW_LOOKANDFEEL=$LIGHT_LOOKANDFEEL
        NEW_COLORSCHEME=$LIGHT_COLORSCHEME
        NEW_ACCENTCOLOR=$LIGHT_ACCENTCOLOR
        NEW_GTKTHEME=$LIGHT_GTKTHEME
        NEW_SHADOW=$LIGHT_SHADOW
        NEW_ICONS=$LIGHT_ICONS
        NEW_KONSOLE=$LIGHT_KONSOLE
        NEW_VSCODETHEME=$VSCODE_LIGHTTHEME
        ;;
    dark)
        NEW_WALLPAPER=$DARK_WALLPAPER
        NEW_DESKTOPTHEME=$DARK_DESKTOPTHEME
        NEW_LOOKANDFEEL=$DARK_LOOKANDFEEL
        NEW_GTKTHEME=$DARK_GTKTHEME
        NEW_COLORSCHEME=$DARK_COLORSCHEME
        NEW_ACCENTCOLOR=$DARK_ACCENTCOLOR
        NEW_SHADOW=$DARK_SHADOW
        NEW_ICONS=$DARK_ICONS
        NEW_KONSOLE=$DARK_KONSOLE
        NEW_VSCODETHEME=$VSCODE_DARKTHEME
        ;;
    darker)
        NEW_WALLPAPER=$DARKER_WALLPAPER
        NEW_DESKTOPTHEME=$DARKER_DESKTOPTHEME
        NEW_LOOKANDFEEL=$DARKER_LOOKANDFEEL
        NEW_GTKTHEME=$DARKER_GTKTHEME
        NEW_COLORSCHEME=$DARKER_COLORSCHEME
        NEW_ACCENTCOLOR=$DARKER_ACCENTCOLOR
        NEW_SHADOW=$DARKER_SHADOW
        NEW_ICONS=$DARKER_ICONS
        NEW_KONSOLE=$DARKER_KONSOLE
        NEW_VSCODETHEME=$VSCODE_DARKERTHEME
        ;;
    black)
        NEW_WALLPAPER=$BLACK_WALLPAPER
        NEW_DESKTOPTHEME=$BLACK_DESKTOPTHEME
        NEW_LOOKANDFEEL=$BLACK_LOOKANDFEEL
        NEW_GTKTHEME=$BLACK_GTKTHEME
        NEW_COLORSCHEME=$BLACK_COLORSCHEME
        NEW_ACCENTCOLOR=$BLACK_ACCENTCOLOR
        NEW_SHADOW=$BLACK_SHADOW
        NEW_ICONS=$BLACK_ICONS
        NEW_KONSOLE=$BLACK_KONSOLE
        NEW_VSCODETHEME=$VSCODE_BLACKTHEME
        ;;
    *)
        echo Only light, dark, darker, black allowed as parameter.
        exit 1
        ;;
esac

switchWallpaper $NEW_WALLPAPER
switchDesktoptheme $NEW_DESKTOPTHEME
switchLookandfeel $NEW_LOOKANDFEEL
switchGtktheme $NEW_GTKTHEME
switchColorscheme $NEW_COLORSCHEME $NEW_ACCENTCOLOR
switchShadow $NEW_SHADOW
switchIcons $NEW_ICONS
switchKonsole $NEW_KONSOLE
switchVSCode $NEW_VSCODETHEME

#
# reload config to apply changes
qdbus org.kde.KWin /KWin org.kde.KWin.reconfigure

#
# write config
kwriteconfig5 --file $CONFIG_FILE --group General --key CurrentTheme $NEW_THEME

# #########################################################
# END OF SCRIPT
# #########################################################
