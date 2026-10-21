#!/bin/sh
# Build Jiggler.app without Xcode (Command Line Tools only).
# ibtool needs Xcode, so the compiled nibs/assets are taken from an official Jiggler.app of the same version.
#   ./build.sh /path/to/official/Jiggler.app   -> build/Jiggler.app
#   ./build.sh test                             -> run the schedule self-check
set -e
cd "$(dirname "$0")"
CFLAGS="-fno-objc-arc -include Jiggler_Prefix.h -mmacosx-version-min=10.15 -arch arm64 -arch x86_64 -Wno-deprecated-declarations"

if [ "$1" = test ]; then
	mkdir -p build && clang $CFLAGS -DDEBUG -framework Cocoa ScheduleController.m test_schedule.m -o build/test_schedule
	exec build/test_schedule
fi

SRC_APP="${1:?usage: ./build.sh /path/to/official/Jiggler.app}"
APP="build/Jiggler Scheduler.app"
rm -rf "$APP" && mkdir -p "$APP/Contents/MacOS"
cp -R "$SRC_APP/Contents/Resources" "$SRC_APP/Contents/Info.plist" "$SRC_APP/Contents/PkgInfo" "$APP/Contents/"
# Own identity, so macOS's Accessibility permission doesn't get matched against the official, differently-signed Jiggler
plutil -replace CFBundleIdentifier -string io.github.semjuel19.jigglerscheduler "$APP/Contents/Info.plist"
plutil -replace CFBundleName -string "Jiggler Scheduler" "$APP/Contents/Info.plist"
plutil -replace CFBundleShortVersionString -string "1.10-scheduler.1" "$APP/Contents/Info.plist"
plutil -replace NSHumanReadableCopyright -string "Jiggler Scheduler, unofficial fork of Jiggler 1.10 (c) 2025 Stick Software. GPL v3." "$APP/Contents/Info.plist"
# Text resources need no compiling, so use this repo's versions (they carry the fork notice)
cp Base.lproj/*.strings "Base.lproj/Read Me.html" "$APP/Contents/Resources/Base.lproj/"
clang $CFLAGS -O2 -framework Cocoa -framework IOKit -framework ApplicationServices \
	main.m AppDelegate.m CocoaExtra.m JigglerOverlayWindow.m PrefsController.m ScheduleController.m \
	SSCPU.m SSPanels.m SSProgressPanel.m SSVersionChecker.m TimedQuitController.m \
	-o "$APP/Contents/MacOS/Jiggler"
codesign --force --deep -s - "$APP"
echo "built $APP"
