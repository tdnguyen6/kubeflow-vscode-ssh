#! /usr/bin/env bash

if [[ "$AUTH_METHOD" -eq "token" ]]; then
  AUTH_HEADERS=(
    --header "Authorization: Bearer $API_TOKEN"
  )
else
  AUTH_HEADERS=(
    --header "x-auth-key: $AUTH_KEY"
    --header "x-auth-email: $AUTH_EMAIL"
  )
fi

SSH_HOST_ESCAPED=${SSH_HOST//\//\\\/} # escape forward slash

START_PATTERN="# Added by Kubeflow SSH:"
END_PATTERN="# End of Kubeflow SSH:"

#################################### PRIVATE KEY ####################################
CREDENTIAL_DIR=~/.ssh/kubeflow/$SSH_HOST

mkdir -p $CREDENTIAL_DIR
curl -L "${AUTH_HEADERS[@]}" "${API_ENDPOINT}id_rsa" -o $CREDENTIAL_DIR/id_rsa
#################################### PRIVATE KEY ####################################

#################################### SSH CONFIG ####################################
SSH_CONFIG="Host $SSH_HOST
	HostName localhost
	ProxyCommand chisel client ${AUTH_HEADERS[@]} $API_ENDPOINT :stdio:%h:%p
	User jovyan
	IdentityFile $CREDENTIAL_DIR/id_rsa
	StrictHostKeyChecking yes"

sed -i "/^$START_PATTERN $SSH_HOST_ESCAPED/,/^$END_PATTERN $SSH_HOST_ESCAPED/d" ~/.ssh/config

echo -e "$START_PATTERN $SSH_HOST\n$SSH_CONFIG\n$END_PATTERN $SSH_HOST" >> ~/.ssh/config
#################################### SSH CONFIG ####################################

#################################### HOST KEYS ####################################
HOST_KEYS=$(curl -L "${AUTH_HEADERS[@]}" "${API_ENDPOINT}host-keys")

sed -i "/^$START_PATTERN $SSH_HOST_ESCAPED/,/^$END_PATTERN $SSH_HOST_ESCAPED/d" ~/.ssh/known_hosts

echo -e "$START_PATTERN $SSH_HOST\n$HOST_KEYS\n$END_PATTERN $SSH_HOST" >> ~/.ssh/known_hosts
#################################### HOST KEYS ####################################
