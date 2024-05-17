#!/bin/bash

cputemp=($(
	sensors coretemp-isa-0000 | sed \
		-e '/^Package id/!d' \
		-e 's/^Package id \([0-9]:  +[0-9\.]\+\)°C .*$/cpu \1 °C/g' \
		-e 's/ \+/ /g'
))

hddtemp=

echo "${cputemp[@]}"
