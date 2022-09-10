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
#   - as Breeze, and "Default Light+" (vs-code) are default you only need
#       - the wallpaper/s
#       - Konsole profiles for light and darker
#       - A Breeze colortheme for vs-code
#
# ---------------------------------------------------------


# #########################################################
# init - set variables -
# #########################################################

# read config
CONFIG_FILE=$HOME/.config/toggletheme.cfg
CURRENT_THEME=$(kreadconfig5 --file $CONFIG_FILE --group General --key CurrentTheme)

# colors for window border shadow
BLACK="0,0,0" #000000
BLUE="61,174,233" #3daee9
ORANGE="246,116,0" #ffa200

# picture for wallpaper all monitors and lockscreen
SWITCH_WALLPAPER="y"
LIGHT_WALLPAPER="$HOME/Bilder/Wallpapers/ventura.jpg"
DARK_WALLPAPER="$HOME/Bilder/Wallpapers/ventura-dark.jpg"
DARKER_WALLPAPER="$HOME/Bilder/Wallpapers/ventura-dark.jpg"

# desktoptheme - aka Plasma Style
# SHOULD ALWAYS BE SET TO "default" and should be set initially for script to work!
#   default         <<<--- we need this one always to follow colorscheme
#   breeze-dark
#   breeze-light
SWITCH_DESKTOPTHEME="y"
LIGHT_DESKTOPTHEME="default"
DARK_DESKTOPTHEME="default"
DARKER_DESKTOPTHEME="default"

# look-and-feel - a.k.a. Global Design
#   org.kde.breeze.desktop
#   org.kde.breezedark.desktop
#   org.kde.breezetwilight.desktop  <<<--- as an alternative for light
SWITCH_LOOKANDFEEL="y"
LIGHT_LOOKANDFEEL="org.kde.breeze.desktop"
DARK_LOOKANDFEEL="org.kde.breezedark.desktop"
DARKER_LOOKANDFEEL="org.kde.breezedark.desktop"

# colorscheme
SWITCH_COLORSCHEME="y"
LIGHT_COLORSCHEME="BreezeClassic"
DARK_COLORSCHEME="BreezeClassicDarkInactiveDimmed"
DARKER_COLORSCHEME="KritaDarkOrange"

# window border shadow color
SWITCH_SHADOW="y"
LIGHT_SHADOW=$BLACK
DARK_SHADOW=$BLUE
DARKER_SHADOW=$ORANGE

# icon set
SWITCH_ICONS="y"
LIGHT_ICONS="breeze"
DARK_ICONS="breeze-dark"
DARKER_ICONS="breeze-dark"

# konsole colors
SWITCH_KONSOLE="y"
# create corresponding konsole profiles. put name without extension here.
LIGHT_KONSOLE="BlackOnWhite"
DARK_KONSOLE="Breeze"
DARKER_KONSOLE="Breeze"

# vs-code colortheme
SWITCH_VSCODE="y"
VSCODE_LIGHTTHEME="Default Light+"
VSCODE_DARKTHEME="Breeze Dark"
VSCODE_DARKERTHEME="Breeze Dark"


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
    fi
}

switchColorscheme() {
    if [[ $SWITCH_COLORSCHEME == "y" ]] ; then
        plasma-apply-colorscheme $1
    fi
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
            $(qdbus org.kde.konsole-$PID /Sessions/1 org.kde.konsole.Session.setProfile $1)
        done
    fi
}

switchVSCode () {
    if [[ $SWITCH_VSCODE == "y" ]] ; then
#         #
#         # hard replacement of colorTheme string in settings.json
#         case $1 in
#             light)
#                 $(sed -i -e "s/\"workbench.colorTheme.*$/\"workbench.colorTheme\": \"Default Light+\",/" ~/.config/Code/User/settings.json)
#                 ;;
#             dark)
#                 $(sed -i -e "s/\"workbench.colorTheme.*$/\"workbench.colorTheme\": \"Breeze Dark\",/" ~/.config/Code/User/settings.json)
#                 ;;
#             darker)
#                 $(sed -i -e "s/\"workbench.colorTheme.*$/\"workbench.colorTheme\": \"Breeze Dark\",/" ~/.config/Code/User/settings.json)
#                 ;;
#         esac
        $(sed -i -e "s/\"workbench.colorTheme.*$/\"workbench.colorTheme\": \"$NEW_VSCODETHEME\",/" ~/.config/Code/User/settings.json)
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
        light | dark | darker )
            NEW_THEME=$1
            ;;
        *)
            echo Only light, dark, darker allowed as parameter.
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
        NEW_SHADOW=$LIGHT_SHADOW
        NEW_ICONS=$LIGHT_ICONS
        NEW_KONSOLE=$LIGHT_KONSOLE
        NEW_VSCODETHEME=$VSCODE_LIGHTTHEME
        ;;
    dark)
        NEW_WALLPAPER=$DARK_WALLPAPER
        NEW_DESKTOPTHEME=$DARK_DESKTOPTHEME
        NEW_LOOKANDFEEL=$DARK_LOOKANDFEEL
        NEW_COLORSCHEME=$DARK_COLORSCHEME
        NEW_SHADOW=$DARK_SHADOW
        NEW_ICONS=$DARK_ICONS
        NEW_KONSOLE=$DARK_KONSOLE
        NEW_VSCODETHEME=$VSCODE_DARKTHEME
        ;;
    darker)
        NEW_WALLPAPER=$DARKER_WALLPAPER
        NEW_DESKTOPTHEME=$DARKER_DESKTOPTHEME
        NEW_LOOKANDFEEL=$DARKER_LOOKANDFEEL
        NEW_COLORSCHEME=$DARKER_COLORSCHEME
        NEW_SHADOW=$DARKER_SHADOW
        NEW_ICONS=$DARKER_ICONS
        NEW_KONSOLE=$DARKER_KONSOLE
        NEW_VSCODETHEME=$VSCODE_DARKERTHEME
        ;;
    *)
        echo Only light, dark, darker allowed as parameter.
        exit 1
        ;;
esac

switchWallpaper $NEW_WALLPAPER
switchDesktoptheme $NEW_DESKTOPTHEME
switchLookandfeel $NEW_LOOKANDFEEL
switchColorscheme $NEW_COLORSCHEME
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
