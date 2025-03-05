#!/bin/bash -e

set -x

VERSION=${1:-1.24.0}
MIRROR="${MIRROR:-https://mirrors.mtdcy.top}"

ARCH="$(uname -s)"
case "$(uname -m)" in
	x86_64) ARCH="$ARCH-amd64"  ;;
	*) ARCH="$ARCH-$(uname -m)" ;;
esac

ARCH=${ARCH,,}
if curl --fail -sL -o /dev/null "$MIRROR"; then
	curl --fail -sL -# "$MIRROR/golang/go$VERSION.$ARCH.tar.gz" | tar -C "$HOME/.go" -xz
else
	curl --fail -sL -# "https://go.dev/dl/go$VERSION.$ARCH.tar.gz" | tar -C "$HOME/.go" -xz
fi
