# toggletheme

Toggle plasma breeze theme between light / dark including vs-code and konsole.

Currently it provides a simple light / dark switch when called with no parameters or a direct switch to currently supported values (light, dark, darker, black).

## install

Just put it somewhere in your path. Config file will be created on first invokation.

## what is supported?

- wallpaper (all monitors)
- plasma style
- overall look and feel
- plasma colorscheme
- lockscreen wallpaper
- window decoration shadow color
- icon theme
- task switcher theme
- konsole profile (profiles need to be created first)
- vs code

## helpers to find installed schemes / themes

```
plasma-apply-desktoptheme --list-themes
plasma-apply-lookandfeel -l
plasma-apply-cursortheme --list-themes
plasma-apply-colorscheme --list-schemes
```
