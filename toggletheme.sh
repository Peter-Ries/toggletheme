#!/bin/bash


# ---------------------------------------------------------
#
# toggletheme
#   switch wallpaper, colorscheme, ... between dark / light
#
#   ToDo:
#       vs-code
#       auto parameter for switch on sunrise/sundown
#
# ---------------------------------------------------------


# #########################################################
# init
# #########################################################

config_file=$HOME/.config/toggletheme.cfg
current_theme=$(cat $config_file)

switch_wallpaper="y"
darker_wallpaper="$HOME/Bilder/Wallpapers/ventura-dark.jpg"
dark_wallpaper="$HOME/Bilder/Wallpapers/ventura-dark.jpg"
light_wallpaper="$HOME/Bilder/Wallpapers/ventura.jpg"

switch_shadow="y"
darker_shadow="246,116,0" #ffa200
dark_shadow="61,174,233" #3daee9
light_shadow="0,0,0" #000000

switch_colorscheme="y"
darker_colorscheme="KritaDarkOrange"
dark_colorscheme="BreezeClassicDarkInactiveDimmed"
light_colorscheme="BreezeClassic"

switch_konsole="y"
darker_konsole="Breeze"
dark_konsole="Breeze"
light_konsole="BlackOnWhite"

switch_vscode="y"


# #########################################################
# functions
# #########################################################

switchWallpaper() {
    if [[ $switch_wallpaper == "y" ]] ; then
        # switch wallpaper
        plasma-apply-wallpaperimage $1
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
        # reload config to apply
        qdbus org.kde.KWin /KWin org.kde.KWin.reconfigure
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

updateConfig () {
    echo $1 > $config_file
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
        new_vscode=$new_theme
        new_konsole=$light_konsole
        new_shadow=$light_shadow
        ;;
    dark)
        new_wallpaper=$dark_wallpaper
        new_colorscheme=$dark_colorscheme
        new_vscode=$new_theme
        new_konsole=$dark_konsole
        new_shadow=$dark_shadow
        ;;
    darker)
        new_wallpaper=$darker_wallpaper
        new_colorscheme=$darker_colorscheme
        new_vscode=$new_theme
        new_konsole=$darker_konsole
        new_shadow=$darker_shadow
        ;;
    *)
        echo Only light, dark, darker allowed as parameter.
        exit 1
        ;;
esac

switchWallpaper $new_wallpaper
switchColorscheme $new_colorscheme
switchShadow $new_shadow
switchVSCode $new_vscode
switchKonsole $new_konsole
updateConfig $new_theme

# #########################################################
# END OF SCRIPT
# #########################################################
