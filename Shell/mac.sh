#!/bin/bash

tr -dc A-F0-9 < /dev/urandom | head -c 10 -z | sed -r 's/(..)/\1:/g;s/:$//;s/^/02:/'
