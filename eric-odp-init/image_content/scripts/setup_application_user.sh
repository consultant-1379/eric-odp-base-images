#!/bin/bash

MAIN_APPLICATION_USER_HOME_DIR=$HOME
ENM_LOGIN_FILE=$HOME/.enm_login
ERIC_ODP_TOKEN_FILE=$ERIC_ODP_HOME/.enm_login


function create_user_homedir() {
  if [ ! -d "$MAIN_APPLICATION_USER_HOME_DIR" ]; then
    mkdir -p $MAIN_APPLICATION_USER_HOME_DIR

    if [ $? -eq 0 ]; then
      echo "Created user's home directory: $MAIN_APPLICATION_USER_HOME_DIR"
    else
      echo "Could not create user's home directory: $MAIN_APPLICATION_USER_HOME_DIR"
      exit 1
    fi
  else
    echo "User's home directory already exists: $MAIN_APPLICATION_USER_HOME_DIR"
  fi
}

function chmod_user_homedir() {
  chmod 700 $MAIN_APPLICATION_USER_HOME_DIR

  if [ $? -eq 0 ]; then
    echo "Permissions set for user's home directory: $MAIN_APPLICATION_USER_HOME_DIR"
    stat "$MAIN_APPLICATION_USER_HOME_DIR" | grep -i -E "access.*uid"
  else
    echo "Could not set permissions for user's home directory: $MAIN_APPLICATION_USER_HOME_DIR"
    exit 1
  fi
}

function create_and_setup_user_homedir() {
  create_user_homedir
  chmod_user_homedir
}

function create_or_update_enm_login_file() {
  log_message=""
  if [ -f "$ENM_LOGIN_FILE" ]; then
    log_message="Updated SSO token file $ENM_LOGIN_FILE"
  else
    log_message="Created SSO token file $ENM_LOGIN_FILE"
  fi

  echo "$SSO_TOKEN" >$ERIC_ODP_TOKEN_FILE
  if [ $? -eq 0 ]; then
    echo "$log_message"
    ln -s -f $ERIC_ODP_TOKEN_FILE $ENM_LOGIN_FILE
  else
    echo "Could not write SSO token file: $ENM_LOGIN_FILE"
  fi
}

function main() {
  create_and_setup_user_homedir
  create_or_update_enm_login_file
}

main
