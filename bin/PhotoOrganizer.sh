#!/bin/bash
#
# photo.sh <src> <dest>

. $(dirname $(readlink -f $0))/xlib.sh

[ $# -lt 2 ] && xlog "usage: $0 <src dir> <dst dir>" && exit 1

src="$1"
dst="$2"

is_video_file() {
	case $(echo "$1" | tr 'A-Z' 'a-z') in 
		*.mov|*.mp4|*.mkv|*.m4a|*.3gp)	return 0;;
		*)								return 1;;
	esac
}

extract_timestamp() {
	ts=
	if is_video_file "$1"; then
		ts=$(synomediaparser "$1" | grep "szMDate" | cut -d: -f2- | sed -e 's/[-:",]/ /g')
	else
		ts=$(exiv2 pr "$file" 2> /dev/null | grep "Image timestamp" | cut -d: -f2- | sed -e 's/:/ /g')
	fi

	# empty string ?
	# all 0s ?
	[ ! -z "$ts" -a "$ts" != " " ] && echo $ts | grep -e '[1-9]' > /dev/null && echo "$ts" && return 0

	# take modify date instead 
	echo $(stat -c %y "$1" | cut -d. -f1 | sed -e 's/[-:]/ /g') && return 0
}

findc="find \"$src\" -type f"

# ignore @eaDir for DSM
findc+=" -not -path \"*/@eaDir/*\""

eval $findc | while read file; do
	# parse time string
	read -r y m d H M S <<< $(extract_timestamp "$file")

	p="IMG"
	is_video_file "$file" && p="VID"

	# check whether target exists
	target="$dst/$y/$m/${p}_$y$m${d}_$H$M$S."${file##*.}

	exists=0
	while [ -f "$target" ]; do
		sum0=$(md5sum "$file" | cut -d' ' -f1)
		sum1=$(md5sum "$target" | cut -d' ' -f1)

		[ "$sum0" = "$sum1" ] && exists=1 && break

		S=$(expr $S + 1)

		target="$dst/$y/$m/${p}_$y$m${d}_$H$M$S."${file##*.}
	done

	[ $exists -gt 0 ] && xlog "$file => $target exists ..." && continue

	xlog "$file => $target"

	mkdir -pv $(dirname "$target")
	cp -a "$file" "$target"
done
