#!/bin/bash

MAIN_APPLICATION_USER_UID=$(printenv MAIN_APPLICATION_USER_UID) #to convert to integer

function add_groups_for_application_user() {
  cat /etc/group > $ERIC_ODP_HOME/group
  #echo ""> $ERIC_ODP_HOME/group
  IFS=";"
  read -ra APP_USER_GROUPS <<<"$MAIN_APPLICATION_USER_GROUPS"
  for USER_GROUP in "${APP_USER_GROUPS[@]}";
  do
    echo -e "USER_GROUP $USER_GROUP \n"
    IFS=":"
    read -ra GROUP_PROPERTY <<< "$USER_GROUP"
    local GROUP_ENTRY="${GROUP_PROPERTY[0]}:x:${GROUP_PROPERTY[1]}:$MAIN_APPLICATION_USER_NAME"
    echo -e "$GROUP_ENTRY" >> $ERIC_ODP_HOME/group
    unset USER_GROUP
    unset GROUP_PROPERTY
  done

  echo "Groups initialized for application user name: $MAIN_APPLICATION_USER_NAME"
}

function add_primary_group_info_for_application_user() {
  cat /etc/passwd | head -n -1 > $ERIC_ODP_HOME/passwd
  echo "$MAIN_APPLICATION_USER_NAME:x:$MAIN_APPLICATION_USER_UID:$MAIN_APPLICATION_USER_PRIMARY_GID::/home/shared/$MAIN_APPLICATION_USER_NAME:/bin/bash" >> $ERIC_ODP_HOME/passwd

  echo "Primary group info added for application user: Uid=$MAIN_APPLICATION_USER_UID ($MAIN_APPLICATION_USER_NAME), Gid=$MAIN_APPLICATION_USER_PRIMARY_GID"
}

function set_up_password_for_application_user() {
  users_password=$SSO_TOKEN
  generated_salt=$(openssl rand -hex 31)
  hashed_password=$(echo $users_password |  openssl passwd -6 -salt $generated_salt -stdin)

  echo "Hashed password created for application user: $MAIN_APPLICATION_USER_NAME"

  echo "$MAIN_APPLICATION_USER_NAME:$hashed_password:19537:1:365:7:::" >> $ERIC_ODP_HOME/shadow

  echo "Shadow file created for application user: $MAIN_APPLICATION_USER_NAME"

}

add_groups_for_application_user
add_primary_group_info_for_application_user
set_up_password_for_application_user
