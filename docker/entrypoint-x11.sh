#!/bin/bash
set -x

echo $_USER
echo $_UID
echo $_GID
echo $_PASSWD_HASH


groupadd --gid $_GID fakename
adduser --uid $_UID --gid $_GID -G wheel --password $_PASSWD_HASH $_USER

ssh-keygen -f /etc/ssh/ssh_host_rsa_key -N '' -t rsa
ssh-keygen -f /etc/ssh/ssh_host_ecdsa_key -N '' -t ecdsa
ssh-keygen -f /etc/ssh/ssh_host_ed25519_key -N '' -t ed25519

dbus-uuidgen --ensure

set +x
echo "In this container, set the password for your user:"
echo "    sudo passwd $_USER"
echo "Then, in a new terminal, ssh into the container"
echo "    ssh -X -p 2222 $_USER@localhost"
echo "Note that you will have to remove the RSA key with every new container."
echo "Within the ssh session, run:"
echo "    module add gcc anaconda qt icc"
echo "then the user interface should be available. You can also compile."


rm /usr/lib/tmpfiles.d/systemd-nologin.conf
echo "X11Forwarding yes" >> /etc/ssh/sshd_config
echo "X11UseLocalhost no" >> /etc/ssh/sshd_config
#echo "X11UseForwarding yes" >> /etc/ssh/sshd_config

exec /usr/sbin/init
#exec su $_USER "$@"

