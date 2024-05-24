#!/bin/sh

res=$(playerctl metadata --all-players --format '{{ status }}: {{ artist }} - {{ title }}')
retVal=$?
if [ $retVal -eq 1 ]; then
    # No Playback but its fine
    exit 0
fi
echo $res
exit $retVal
