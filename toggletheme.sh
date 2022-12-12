#!/bin/bash

# ---------------------------------------------------------
#
# toggletheme
#   - switch wallpaper, colorscheme, ... between dark / light
#
#   - works best with default Breeze theme "following current color scheme"
#   - window shadow color may not work with other window decorations than Breeze (breezerc)
#   - script does not check if wallpaper, vs-code theme, konsole profile exist
#
#   - you only need:
#       - wallpaper/s for each theme
#       - KDE colorschemes used here KritaDarkOrange, FlatRemixBlueDarkest
#       - VS-Code themes used here: Simple Dark, Just Black
#       - create Konsole profiles for your needs
#
# ---------------------------------------------------------

# #########################################################
# functions
# #########################################################



createTogglethemerc() {

echo Creating new config file $HOME/.config/togglethemerc
echo Please adjust settings and start script again!

cat << EOF > $HOME/.config/togglethemerc
# Colors used
#
# RGB colors for window border shadow
# RGB_BLACK="0,0,0" #000000
# RGB_BLUE="61,174,233" #3daee9
# RGB_BLUE_BLACK="39,119,255" #2777ff
# RGB_ORANGE="246,116,0" #ffa200
#
# HEX colors for accent
# HEX_BLUE="#3daee9"
# HEX_BLUE_BLACK="#2777ff"
# HEX_ORANGE="#ffa200"
#
#
# ::: desktoptheme - aka Plasma Style - SHOULD ALWAYS BE SET TO "default" and should be set initially for script to work!
# > plasma-apply-desktoptheme --list-themes
#   default         <<<--- we need this one always to follow colorscheme
#   breeze-dark
#   breeze-light
#
#
# ::: look-and-feel - a.k.a. Global Design
# > plasma-apply-lookandfeel -l
#   org.kde.breeze.desktop
#   org.kde.breezedark.desktop
#   org.kde.breezetwilight.desktop  <<<--- as an alternative for light
#
#
# ::: colorschemes
# > plasma-apply-colorscheme --list-schemes
#
#
# ::: cursorthemes
# > plasma-apply-cursortheme --list-themes
#
#
# ::: Wallpapers
# I recommend using links to fixed names for wallpapers instead of real filenames here
#

[General]
CurrentTheme=none

[Switch]
ColorScheme=y
DesktopTheme=y
GTKTheme=y
Icons=y
Konsole=y
LookAndFeel=y
Shadow=y
SplashScreen=n
TaskSwitcher=y
VSCode=y
Wallpaper=y

[TaskSwitcher]
Style=thumbnail_grid

[black]
ColorScheme=FlatRemixBlueDarkest
DesktopTheme=default
GTKTheme=Breeze
Icons=breeze-dark
Konsole=BlackBlue
LookAndFeel=org.kde.breezedark.desktop
Shadow=39,119,255
VSCode=Just Black
Wallpaper=/home/peter/Bilder/Wallpapers/wallpaper-black

[dark]
ColorScheme=BreezeClassicDarkInactiveDimmed
DesktopTheme=default
GTKTheme=Breeze
Icons=breeze-dark
Konsole=Breeze
LookAndFeel=org.kde.breezedark.desktop
Shadow=61,174,233
VSCode=Simple Dark
Wallpaper=/home/peter/Bilder/Wallpapers/wallpaper-dark

[darker]
ColorScheme=FlatRemixBlueDark
DesktopTheme=default
GTKTheme=Breeze
Icons=breeze-dark
Konsole=Breeze
LookAndFeel=org.kde.breezedark.desktop
Shadow=246,116,0
VSCode=Atom One Dark
Wallpaper=/home/peter/Bilder/Wallpapers/wallpaper-darker

[light]
ColorScheme=BreezeClassicLight
DesktopTheme=default
GTKTheme=Breeze
Icons=breeze
Konsole=BlackOnWhite
LookAndFeel=org.kde.breeze.desktop
Shadow=0,0,0
VSCode=Default Light+
Wallpaper=/home/peter/Bilder/Wallpapers/wallpaper-light

EOF

exit 0

}



switchWallpaper() {
    if [[ $(kreadconfig5 --file $CONFIG_FILE --group Switch --key Wallpaper) == "y" ]] ; then
        #
        # switch wallpaper
        echo ::: Switch wallpaper to $1
        plasma-apply-wallpaperimage $1
        #
        # switch lockscreen wallpaper
        echo ::: Switch lockscreen background to $1
        kwriteconfig5 --file kscreenlockerrc --group Greeter --group Wallpaper --group org.kde.image --group General --key Image "file://$1"
    fi
}



switchDesktoptheme() {
    if [[ $(kreadconfig5 --file $CONFIG_FILE --group Switch --key DesktopTheme) == "y" ]] ; then
        echo ::: Switch DesktopTheme to $1
        plasma-apply-desktoptheme $1
    fi
}



switchLookandfeel() {
    if [[ $(kreadconfig5 --file $CONFIG_FILE --group Switch --key LookAndFeel) == "y" ]] ; then
        echo ::: Switch LookAndFeel to $1
        plasma-apply-lookandfeel --apply $1
    fi

    # splashscreen none or breeze?
    if [[ $(kreadconfig5 --file $CONFIG_FILE --group Switch --key SplashScreen ) == "y" ]] ; then
        # breeze is default and has an empty ksplashrc - so delete entries
        echo ::: Switch SplashScreen to $1
        kwriteconfig5 --file ksplashrc --group KSplash --key Engine --delete
        kwriteconfig5 --file ksplashrc --group KSplash --key Theme --delete
    else
        echo ::: Disabling SplashScreen
        kwriteconfig5 --file ksplashrc --group KSplash --key Engine None
        kwriteconfig5 --file ksplashrc --group KSplash --key Theme None
    fi

    # use different taskswitcher?
    if [[ $(kreadconfig5 --file $CONFIG_FILE --group Switch --key TaskSwitcher) == "y" ]] ; then
        TASKSWITCHER_STYLE=$(kreadconfig5 --file $CONFIG_FILE --group TaskSwitcher --key Style)
        echo ::: Switch TaskSwitcher Style to $TASKSWITCHER_STYLE
        kwriteconfig5 --file kwinrc --group TabBox --key LayoutName $TASKSWITCHER_STYLE
    fi
}



switchGtktheme() {
    if [[ $(kreadconfig5 --file $CONFIG_FILE --group Switch --key GTKTheme) == "y" ]] ; then
        echo ::: Switch GTKTheme to $1
        qdbus org.kde.GtkConfig /GtkConfig org.kde.GtkConfig.setGtkTheme $1
    fi
}



switchColorscheme() {
    if [[ $(kreadconfig5 --file $CONFIG_FILE --group Switch --key ColorScheme) == "y" ]] ; then
        echo ::: Switch ColorScheme to $1
        plasma-apply-colorscheme $1
    fi
}



switchShadow() {
    if [[ $(kreadconfig5 --file $CONFIG_FILE --group Switch --key Shadow) == "y" ]] ; then
        #
        # set ShadowColor (R,G,B) in $HOME/.config/breezerc
        echo ::: Switch Window ShadowColor to $1
        kwriteconfig5 --file breezerc --group Common --key ShadowColor $1
    fi
}



switchIcons() {
    if [[ $(kreadconfig5 --file $CONFIG_FILE --group Switch --key Icons) == "y" ]] ; then
        echo ::: Switch Icons to $1
        /usr/lib/plasma-changeicons $1
    fi
}



switchKonsole () {
    if [[ $(kreadconfig5 --file $CONFIG_FILE --group Switch --key Konsole) == "y" ]] ; then
        #
        # define Breeze.profile and BlackOnWhite.profile profiles first for konsole!
        # set default profile for new instances
        echo ::: Switch Konsole Profile to $1
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
    if [[ $(kreadconfig5 --file $CONFIG_FILE --group Switch --key VSCode) == "y" ]] ; then
        #
        # modify settings directly with sed in ~/.config/Code/User/settings.json
        echo ::: Switch VSCode Theme to $1
        sed -i -e "s/\"workbench.colorTheme\":.*$/\"workbench.colorTheme\": \"$1\",/" ~/.config/Code/User/settings.json
    fi
}




# #########################################################
# main
# #########################################################


#
# check for config - create if not there or if parameter 'init' has been passed#
CONFIG_FILE=$HOME/.config/togglethemerc
if [[ ! -f $CONFIG_FILE || $1 == "init" ]] ; then
    createTogglethemerc
fi


#
# get current theme for easy toggling if no parameter passed
CURRENT_THEME=$(kreadconfig5 --file $CONFIG_FILE --group General --key CurrentTheme)

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


#
# apply values from config file
switchDesktoptheme $(kreadconfig5 --file $CONFIG_FILE --group $NEW_THEME --key DesktopTheme)
switchLookandfeel $(kreadconfig5 --file $CONFIG_FILE --group $NEW_THEME --key LookAndFeel)
switchGtktheme $(kreadconfig5 --file $CONFIG_FILE --group $NEW_THEME --key GTKTheme)
switchColorscheme $(kreadconfig5 --file $CONFIG_FILE --group $NEW_THEME --key ColorScheme)
switchShadow $(kreadconfig5 --file $CONFIG_FILE --group $NEW_THEME --key Shadow)
switchIcons $(kreadconfig5 --file $CONFIG_FILE --group $NEW_THEME --key Icons)
switchWallpaper $(kreadconfig5 --file $CONFIG_FILE --group $NEW_THEME --key Wallpaper)
switchKonsole $(kreadconfig5 --file $CONFIG_FILE --group $NEW_THEME --key Konsole)
switchVSCode "$(kreadconfig5 --file $CONFIG_FILE --group $NEW_THEME --key VSCode)"


#
# reload config to apply changes
echo ::: Reload new settings
qdbus org.kde.KWin /KWin org.kde.KWin.reconfigure


#
# write config
echo ::: Update $CONFIG_FILE settings
kwriteconfig5 --file $CONFIG_FILE --group General --key CurrentTheme $NEW_THEME


# #########################################################
# END OF SCRIPT
# #########################################################
