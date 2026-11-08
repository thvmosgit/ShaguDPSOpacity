# ShaguDPS Opacity

Adds an out-of-combat opacity setting to [OEVG's fork of ShaguDPS](https://octowow.st/git/OEVG/ShaguDPS) for
WoW 1.12. Out of combat, every ShaguDPS window fades to that level. In combat, or while you
hover over a window, it's fully opaque again.

## Usage

Open ShaguDPS's settings. The new **OOC Opacity** row is at the bottom of the "Window"
section; `<` and `>` step between 10% and 100%. At 100% nothing fades. Windows you open
later with the "+" button use the same setting.

It's saved with ShaguDPS's other settings, and ShaguDPS's own files aren't modified.

## Install

Add `https://github.com/daev-code/ShaguDPSOpacity` to your launcher, or `git clone` it into
`Interface\AddOns`. Leave the `.git` folder in place: launchers that install from git need
it to pull updates.

You can also copy the folder to `Interface\AddOns\ShaguDPSOpacity` yourself, but then
you'll need to update it yourself too.
