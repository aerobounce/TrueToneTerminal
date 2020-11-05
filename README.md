
# Terminal.app adjusts ANSI colors implicitly

While I was making a theme for Terminal, I realized the colors I specify would never match to colors shown in Terminal. They were always somewhat brighter.
After researching for a while it turned out Terminal.app **implicitly adjusts ANSI colors according to it's background color**.


# Terminal's private methods

- `adjustedColorWithColor:withBackgroundColor:force:`
- `adjustedColorWithRed:green:blue:alpha:withBackgroundColor:force:`
- `colorForANSIColor:adjustedRelativeToColor:`
- `colorForANSIColor:adjustedRelativeToColor:withProfile:`
- `colorForANSIColor:adjustedRelativeToColor:withProfile:forCopy:`
- `colorForExtendedANSIColor:adjustedRelativeToColor:withProfile:`


# Useful Links

- https://github.com/jenghis/terminal-patch
- https://gitlab.com/gnachman/iterm2/issues/4404
- https://apple.stackexchange.com/questions/282911/prevent-mac-terminal-brightening-font-color-with-no-background
