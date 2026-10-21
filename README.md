Jiggler Scheduler
=================

**An unofficial fork of [Jiggler](https://github.com/bhaller/Jiggler) by Ben Haller / [Stick Software](http://www.sticksoftware.com/software/Jiggler.html), with a weekly scheduler added.**

> ⚠️ **This is not the official Jiggler.** It is a modified version maintained by [Semjuel19](https://github.com/Semjuel19). Stick Software and Ben Haller did not make, review or endorse these changes and are **not responsible** for this fork. Please **report bugs and requests in [this repo's issues](https://github.com/Semjuel19/Jiggler-Scheduler/issues)**, not to the original project or to Stick Software.

## Credits

All of Jiggler itself is the work of **Ben Haller** and **Stick Software**, with contributions from Eric Hankinson; the icon is by Roberto Muñoz. Thank you for writing Jiggler and releasing it as free software. If you find it useful, please check out [Stick Software's other products](http://www.sticksoftware.com).

## What this fork changes

Modified October 2026 by Semjuel19:

- **Schedule...** menu item: pick which days of the week Jiggler may jiggle and from what time to what time. With the schedule on, Jiggler starts and stops by itself based on the Mac's clock; with it off, Jiggler works exactly as before. A window that ends earlier than it starts (e.g. 22:00–02:00) runs past midnight.
- Asks for the macOS permission it needs to move the mouse on launch (the original stays silent on macOS 15+, so jiggling could fail without any hint).
- Its own name and app ID (`Jiggler Scheduler`, `io.github.semjuel19.jigglerscheduler`), so it can't be confused with the official app.
- Home page / support menu items point to this repo; the update check (which would offer the official Jiggler) is removed.

## Install

Download the `.dmg` from [Releases](https://github.com/Semjuel19/Jiggler-Scheduler/releases), open it and drag **Jiggler Scheduler** to Applications. The app is not notarized by Apple, so the first time right-click it and choose **Open**. Then allow it under **System Settings → Privacy & Security → Accessibility** and reopen it.

## Building

With Xcode: open `Jiggler.xcodeproj` and build.

Without Xcode (Command Line Tools only): `ibtool` is unavailable, so `build.sh` reuses the compiled interface files from an official Jiggler 1.10 app:

```sh
./build.sh /path/to/official/Jiggler.app   # -> build/Jiggler Scheduler.app
./build.sh test                            # schedule logic self-check
```

## License

Same as the original: **GNU General Public License v3** (see [LICENSE](LICENSE)). Copyright © Ben Haller / Stick Software; modifications © 2026 Semjuel19, under the same license.

---

# Original Jiggler README

Jiggler
---------------------------------------------------------------------------------------------
Home page: [http://www.sticksoftware.com/software/Jiggler.html](http://www.sticksoftware.com/software/Jiggler.html)

GitHub page: [https://github.com/bhaller/Jiggler](https://github.com/bhaller/Jiggler)

Jiggler is a little freeware app with one purpose: to keep your Mac awake. When you have some lengthy task for your computer to do, it's annoying to have to turn off your screensaver and turn off the sleep timer, only to have to turn it all back on again when you're done. (The "never sleep" corner will keep your screensaver from kicking in, but still won't prevent your machine from falling asleep.) What you really want is a little helper who will bump your mouse every once in a while to keep your machine alert. That's Jiggler.

Jiggler is a [Stick Software](http://www.sticksoftware.com) product.  If you like it, please check out some of our shareware products at [www.sticksoftware.com](http://www.sticksoftware.com) – and pay for them if you use them!


License
----------

Copyright (c) 2021 Ben Haller.  All rights reserved.

Jiggler is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

Jiggler is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with Jiggler.  If not, see [http://www.gnu.org/licenses/](http://www.gnu.org/licenses/).


Development & Feedback
-----------------------------------
Jiggler is not under active development, but we would welcome pull requests with useful features.  If you want us to take your pull request, please don't add features that only you are likely to want (no kitchen sink!), and please try to keep the user interface simple and comprehensible.  Jiggler is already quite complicated for such a simple concept!

Jiggler's code is, well, not great.  Although Jiggler's code was open-sourced in 2016, much of its code was written as much as 15 years ago.  In addition, much of its code is chunks ripped out of other projects that have not been open-sourced, so there are doubtless vestigial relationships and pointless excursions.  If I were writing it today, I would do many things differently.  Be gentle.
