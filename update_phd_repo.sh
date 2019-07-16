#!/bin/bash
# Author:       Olivier van der Toorn
# Description:  Makes sure the local phd git repo is up to date.
GIT_REPO="/home/lordievader/Documents/phd"
GIT_COMMAND="git -C ${GIT_REPO}"
$GIT_COMMAND pull --rebase > /dev/null
$GIT_COMMAND status -s
