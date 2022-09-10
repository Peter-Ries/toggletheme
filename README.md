# toggletheme

Toggle plasma breeze theme between light / dark including some more applications.

The script is easy to read. All variables can be adjusted on top of script as well as the switches what you want to change.

Currently it provides a simple light/dark switch when called with no parameters or a direct switch to currently supported values (light, dark, darker).

The most **tricky** part was to find out what programs/configs are involved to do a most complete theme switch. So it can be used as a small reference as well ;)

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
- konsole profile (profiles need to be created first)
- vs code

# idea / future

- I created a keyboard shortcut Alt+Meta+T for toggletheme.sh so I can easily switch between dark (preferred) and light (when working outside in the sun)
- Idea: create a small Python or whatever script to call toggletheme.sh at
  sunrise/sunset to perform a switch
  - toggleauto.py is a WIP play around script **not working yet**
