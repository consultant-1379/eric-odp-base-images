ERIC_ODP_SSHD_CONFIG_DIR="$ERIC_ODP_HOME/sshd"

mkdir -p $ERIC_ODP_SSHD_CONFIG_DIR

## do not generate rsa and dsa
ssh-keygen -t ecdsa -f $ERIC_ODP_SSHD_CONFIG_DIR/ssh_host_ecdsa_key -N ''
ssh-keygen -t ed25519 -f $ERIC_ODP_SSHD_CONFIG_DIR/ssh_host_ed25519_key -N ''

ls -al $ERIC_ODP_SSHD_CONFIG_DIR

cp /usr/local/etc/sshd_config $ERIC_ODP_SSHD_CONFIG_DIR
