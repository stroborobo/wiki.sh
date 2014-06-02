#!/bin/sh

set -e

MAXWIDTH=100

cmdexists() {
	command -v "$1" >/dev/null 2>&1 && return 0 || return 1
}

if [[ `cmdexists elinks` -eq 1 ]]; then
	echo "$0 depends on elinks."
	exit 10
fi

r=$READER
if [[ "1$r" = "1" ]]; then
	r="less"
fi

width=`tput cols`
if [[ $width -gt $MAXWIDTH ]]; then
	width=$MAXWIDTH
fi

search='https://de.wikipedia.org/wiki/Spezial:Suche?search='
if [[ "1$1" = "1-e" ]]; then
	search='https://en.wikipedia.org/w/index.php?title=Special:Search&search='
	shift
fi
searchterm=`echo "$*" | sed -e 's/ /%20/g'`

url=`curl --silent --head "$search$searchterm" | grep 'Location:' | sed -e 's/Location: //' | tr -d '\r'`
if [[ "1$url" = "1" ]]; then
	echo "No unique result: $*"
	exit 10
fi
url="${url}?printable=yes"

out=`elinks -dump -dump-width $width -force-html -no-references -no-numbering "$url"`
echo "$out" | LANG=C LC_ALL=C sed -e 's/\[Bearbeiten\]//' -e 's/\[Edit\]//' -e '/^   Link: /d' | $r
