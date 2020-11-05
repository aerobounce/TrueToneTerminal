#!/usr/bin/env bash
set -Ceu

DESKTOP_TERMINAL_DIR=~/Desktop/TrueToneTerminal
DESKTOP_TERMINAL_APP=~/Desktop/TrueToneTerminal/Terminal.app

cprint() { printf "\e[32;1m==> \e[m\e[1m%s\e[m\n" "$1"; }

# Move to this script's directory
cprint "cd: Move to this script's directory"
cd "${0%/*}"

# Build dylib
cprint "gcc: Build libTrueToneTerminal.dylib"
gcc -dynamiclib -framework AppKit -o ./libTrueToneTerminal.dylib ./TrueToneTerminal.m

# Copy Terminal.app to Desktop
cprint "cp: Copy Terminal.app to Desktop/TrueToneTerminal"
[[ -e $DESKTOP_TERMINAL_DIR ]] && rm -rf "$DESKTOP_TERMINAL_DIR"
mkdir -p "$DESKTOP_TERMINAL_DIR"
cp -af /Applications/Utilities/Terminal.app "$DESKTOP_TERMINAL_DIR"

# Remove code-sign to apply patch
cprint "codesign: Remove Signature of Terminal.app"
codesign --remove-signature "$DESKTOP_TERMINAL_APP"

# Copy libTrueToneTerminal.dylib into Terminal.app
cprint "cp: Copy libTrueToneTerminal.dylib into Terminal.app"
cp -af ./libTrueToneTerminal.dylib "${DESKTOP_TERMINAL_APP}/Contents/MacOS"

# Rename Terminal ~> terminalbin
cprint "mv: Terminal.app/Contents/MacOS/Terminal ~> Terminal.app/Contents/MacOS/terminalbin"
mv "$DESKTOP_TERMINAL_APP"/Contents/MacOS/Terminal "$DESKTOP_TERMINAL_APP"/Contents/MacOS/terminalbin

# Generate Terminal launch script
cprint "Generating Terminal launch script"
cat << EOL >| "$DESKTOP_TERMINAL_APP"/Contents/MacOS/Terminal
#!/bin/sh
DYLD_INSERT_LIBRARIES="\${0%/*}/libTrueToneTerminal.dylib" "\${0%/*}/terminalbin"
# NSObjCMessageLoggingEnabled=YES DYLD_INSERT_LIBRARIES="\${0%/*}/libTrueToneTerminal.dylib" "\${0%/*}/terminalbin"
# sudo dtrace -s ~/Desktop/trace.d -c "\${0%/*}/terminalbin"
EOL
chmod a+x "$DESKTOP_TERMINAL_APP"/Contents/MacOS/Terminal

# Comment L32-43 and comment below out to use insert_dylib instead.
# ./insert_dylib --inplace @executable_path/libTrueToneTerminal.dylib "$DESKTOP_TERMINAL_APP"/Contents/MacOS/Terminal

# Codesign app
cprint "codesign: ad-hoc signing $DESKTOP_TERMINAL_APP"
# codesign -fs - "$DESKTOP_TERMINAL_APP" --deep
# codesign --verify --verbose "$DESKTOP_TERMINAL_APP"

# Successfull
cprint "TrueToneTerminal: All the steps has done successfully!"
cprint "TrueToneTerminal:
Now, if you want to replace '/Applications/Utilities/Terminal.app', follow the steps below:
1. Go into Recovery mode and disable SIP \`csrutil disable && reboot\`.
2. With TrueToneTerminal/Terminal.app, type: \`sudo rm -rf /Applications/Utilities/Terminal.app\`
3. \`sudo cp -arf $DESKTOP_TERMINAL_APP /Applications/Utilities\`
4. Go into Recovery mode again, and enable SIP \`csrutil enable && reboot\`.
5. Voila! Now TrueToneTerminal is Terminal.app. Enjoy."

open "$DESKTOP_TERMINAL_DIR"
# open "$DESKTOP_TERMINAL_APP"/Contents/MacOS/Terminal
