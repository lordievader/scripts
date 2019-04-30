#!/bin/bash
if [ -z "$(sudo rfkill list wifi|grep yes)" ]; then
    sudo rfkill block wifi
else
    sudo rfkill unblock wifi
fi
