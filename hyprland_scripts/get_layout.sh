#!/bin/sh
COMMAND=$(xset -q | grep LED | awk '{ print $10 }')

case "$COMMAND" in
  ("00000000"|"00000001"|"00000002"|"00000003") LAYOUT="en" ;;
  ("00001000"|"00001001"|"00001002"|"00001003") LAYOUT="ru" ;;
  (*) LAYOUT="??" ;;
esac

echo $LAYOUT
