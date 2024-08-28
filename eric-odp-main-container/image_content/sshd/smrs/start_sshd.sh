mkdir -p /tmp/ssh

if [ ! -f "/tmp/ssh/ssh_host_rsa_key" ]; then
   ##generate host key
   ##would require additional logic for other host key types
   ##and accepting empty password when key is generated
   ssh-keygen -f /tmp/ssh/ssh_host_rsa_key
fi
/usr/sbin/sshd -f /tmp/ssh/sshd_config  -E /tmp/ssh/log_sshd

