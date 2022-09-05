#!/bin/bash


# ---------------------------------------------------------
#
# toggletheme
#   switch wallpaper, colorscheme, ... between dark / light
#
# ---------------------------------------------------------


# #########################################################
# init
# #########################################################

# read config
config_file=$HOME/.config/toggletheme.cfg
current_theme=$(kreadconfig5 --file $config_file --group General --key CurrentTheme)

switch_wallpaper="y"
light_wallpaper="$HOME/Bilder/Wallpapers/ventura.jpg"
dark_wallpaper="$HOME/Bilder/Wallpapers/ventura-dark.jpg"
darker_wallpaper="$HOME/Bilder/Wallpapers/ventura-dark.jpg"

switch_colorscheme="y"
light_colorscheme="BreezeClassic"
dark_colorscheme="BreezeClassicDarkInactiveDimmed"
darker_colorscheme="KritaDarkOrange"

switch_shadow="y"
light_shadow="0,0,0" #000000
dark_shadow="61,174,233" #3daee9
darker_shadow="246,116,0" #ffa200

switch_icons="y"
light_icons="breeze"
dark_icons="breeze-dark"
darker_icons="breeze-dark"

switch_konsole="y"
light_konsole="BlackOnWhite"
dark_konsole="Breeze"
darker_konsole="Breeze"

switch_vscode="y"


# #########################################################
# functions
# #########################################################

switchWallpaper() {
    if [[ $switch_wallpaper == "y" ]] ; then
        #
        # switch wallpaper
        plasma-apply-wallpaperimage $1
        #
        # switch lockscreen wallpaper
        kwriteconfig5 --file kscreenlockerrc --group Greeter --group Wallpaper --group org.kde.image --group General --key Image "file://$1"
    fi
}

switchColorscheme() {
    if [[ $switch_colorscheme == "y" ]] ; then
        plasma-apply-colorscheme $1
    fi
}

switchShadow() {
    if [[ $switch_shadow == "y" ]] ; then
        #
        # set ShadowColor (R,G,B) in $HOME/.config/breezerc
        kwriteconfig5 --file breezerc --group Common --key ShadowColor $1
    fi
}

switchIcons() {
    if [[ $switch_icons == "y" ]] ; then
        /usr/lib/plasma-changeicons $1
    fi
}

switchKonsole () {
    if [[ $switch_konsole == "y" ]] ; then
        #
        # define Breeze.profile and BlackOnWhite.profile profiles first for konsole!
        # set default profile for new instances
        kwriteconfig5 --file konsolerc --group "Desktop Entry" --key "DefaultProfile" $1".profile"
        #
        # apply to all running instances
        IFS=" "
        pids=$(pidof konsole)
        for pid in $pids; do
            $(qdbus org.kde.konsole-$pid /Sessions/1 org.kde.konsole.Session.setProfile $1)
        done
    fi
}

switchVSCode () {
    if [[ $switch_vscode == "y" ]] ; then
        #
        # hard replacement of colorTheme string in settings.json
        case $1 in
            light)
                $(sed -i -e "s/\"workbench.colorTheme.*$/\"workbench.colorTheme\": \"Default Light+\",/" ~/.config/Code/User/settings.json)
                ;;
            dark)
                $(sed -i -e "s/\"workbench.colorTheme.*$/\"workbench.colorTheme\": \"Breeze Dark\",/" ~/.config/Code/User/settings.json)
                ;;
            darker)
                $(sed -i -e "s/\"workbench.colorTheme.*$/\"workbench.colorTheme\": \"Breeze Dark\",/" ~/.config/Code/User/settings.json)
                ;;
        esac
    fi
}




# #########################################################
# main
# #########################################################

if [[ $1 == "" ]] ; then
    #
    # no parameter - only toggle light/dark
    case $current_theme in
        light)
            new_theme="dark"
            ;;
        *)
            new_theme="light"
            ;;
    esac
else
    #
    # parameter -> evaluate
    case $1 in
        light | dark | darker )
            new_theme=$1
            ;;
        *)
            echo Only light, dark, darker allowed as parameter.
            exit 1
            ;;
    esac
fi

case $new_theme in
    light)
        new_wallpaper=$light_wallpaper
        new_colorscheme=$light_colorscheme
        new_shadow=$light_shadow
        new_icons=$light_icons
        new_konsole=$light_konsole
        new_vscode=$new_theme
        ;;
    dark)
        new_wallpaper=$dark_wallpaper
        new_colorscheme=$dark_colorscheme
        new_shadow=$dark_shadow
        new_icons=$dark_icons
        new_konsole=$dark_konsole
        new_vscode=$new_theme
        ;;
    darker)
        new_wallpaper=$darker_wallpaper
        new_colorscheme=$darker_colorscheme
        new_shadow=$darker_shadow
        new_icons=$darker_icons
        new_konsole=$darker_konsole
        new_vscode=$new_theme
        ;;
    *)
        echo Only light, dark, darker allowed as parameter.
        exit 1
        ;;
esac

switchWallpaper $new_wallpaper
switchColorscheme $new_colorscheme
switchShadow $new_shadow
switchIcons $new_icons
switchKonsole $new_konsole
switchVSCode $new_vscode

#
# reload config to apply changes
qdbus org.kde.KWin /KWin org.kde.KWin.reconfigure

#
# write config
kwriteconfig5 --file $config_file --group General --key CurrentTheme $new_theme

# #########################################################
# END OF SCRIPT
# #########################################################
