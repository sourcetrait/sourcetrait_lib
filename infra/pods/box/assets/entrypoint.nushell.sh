#!/bin/sh
umask 077
exec /usr/bin/nu -l "$@"
