#!/bin/sh
# swaylock-effects (fork jirutka, base swaylock 1.7 = ext-session-lock)
# seul fork avec --clock compatible Sway moderne (mortie = input-inhibitor refuse sur Sway 1.11)
# Build vers /usr/local ; le swaylock Debian (/usr/bin) reste intact en fallback.
set -eu

SRC="$HOME/.cache/swaylock-effects-jirutka"

if [ ! -d "$SRC/.git" ]; then
	git clone --depth 1 https://github.com/jirutka/swaylock-effects "$SRC"
fi

cd "$SRC"

if [ -d build ]; then
	meson setup build --prefix=/usr/local --reconfigure
else
	meson setup build --prefix=/usr/local
fi

ninja -C build
echo "Build OK. Installation (sudo) :"
echo "  sudo ninja -C $SRC/build install"
