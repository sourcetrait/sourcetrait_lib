#!/bin/sh
# start nushell as an entrypoint
umask 077
exec /usr/bin/nu -l "$@"
