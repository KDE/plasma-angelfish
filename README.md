# Angelfish

This is an experimental webbrowser designed to 

- be used on small mobile devices,
- integrate well in Plasma workspaces

## Preliminary roadmap:
- [x] browser navigation: back + forward + reload
- [x] browser status
- [x] Implement URL bar
- [x] Error handler in UI
- [x] history store, model and UI
- [x] bookmarks store, model and UI
  - [x] add / remove
- [x] in-window navigation: tabs in bottom bar
- [ ] SSL error handler
- [x] Touch actions (pinch?) (done in QtWebEngine)
- [x] user-agent to request mobile site
- [x] open and close new tabs
- [x] History based completion
- [x] Right click / long press menu
- [x] purpose integration (for kdeconnect)
- [x] adblock

## Development
To debug requests sent by the browser, for example for debugging the ad blocker, it can be useful to have a look at the development tools.
For using them, the browser needs to be started with a special environment variable set: `QTWEBENGINE_REMOTE_DEBUGGING=4321 angelfish`.
The variable contains the port on which the development tools will be available. You can now point another browser to http://localhost:4321.

To enable adblock logging, add the following to `~/.config/QtProject/qtlogging.ini`:
```
[Rules]
org.kde.mobile.angelfish.adblock.debug=true
```

## Flatpak
If one of the Cargo.toml files is updated, the flatpak sources need to be regenerated. That can be done using the `./flatpak/regenerate-sources.sh` script.
