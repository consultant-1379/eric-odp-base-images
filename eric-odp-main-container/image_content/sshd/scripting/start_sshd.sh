#!/bin/bash

#to complete the pod subprocess needs to killed
#other functionality needs to be added to the pod watching if sessions are still opne
#if not open send kill signal:
# kill -15 $(ps aux | grep '/usr/sbin/sshd -D -f /var/lib/extrausers/sshd/sshd_config -e' | awk '{print $2}' | cut -d$'\n' -f1)

if [ -f /ericsson/pod_setup/monitor_user_sessions.sh ]; then
  /ericsson/pod_setup/monitor_user_sessions.sh &
  fi

#if [ -f /ericsson/pod_setup/amos-postStartup.sh ]; then
#  /ericsson/pod_setup/amos-postStartup.sh &
#  fi

/usr/sbin/sshd -D -f $ERIC_ODP_HOME/sshd/sshd_config -e



