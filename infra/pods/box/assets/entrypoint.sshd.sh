#!/bin/sh
# start sshd as an entrypoint
ssh-keygen -A
exec /usr/sbin/sshd -D
