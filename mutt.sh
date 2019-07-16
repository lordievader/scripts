#!/bin/zsh
pwds=`gpg -d ~/.mutt/passwords.gpg`
eval "$pwds"
exec neomutt "$@"
#exec mutt "$@"
