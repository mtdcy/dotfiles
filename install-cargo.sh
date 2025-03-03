#!/bin/bash -e

MIRROR="${MIRROR:-https://mirrors.mtdcy.top}"

if curl --fail -sL "$MIRROR"; then
	export RUSTUP_DIST_SERVER="$MIRROR/rust-static"
	export RUSTUP_UPDATE_ROOT="$MIRROR/rust-static/rustup"
	bash -c "$(curl -fsSL "$MIRROR/misc/rustup-install.sh")"
else
	bash -c "$(curl -fsSL https://sh.rustup.rs)"
fi
