#!/bin/bash -e

MIRROR="${MIRROR:-https://mirrors.mtdcy.top}"

if curl --fail -sL -o /dev/null "$MIRROR"; then
	export DOWNLOAD_URL="$MIRROR/docker-ce"
fi

bash -c "$(curl -fsSL https://get.docker.com)"
