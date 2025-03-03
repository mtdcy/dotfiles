#!/bin/bash -e

MIRROR="${MIRROR:-https://mirrors.mtdcy.top}"

if curl --fail -sL "$MIRROR"; then
	export DOWNLOAD_URL="$MIRROR/docker-ce"
fi

bash -c "$(curl -fsSL https://get.docker.com)"
