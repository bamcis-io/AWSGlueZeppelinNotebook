#!/bin/bash

if [ -z "${DEV_ENDPOINT}" ]; then
	echo "DEV_ENDPOINT must be set."
	exit 1
fi

if [ -z "${USERNAME}" ]; then
	echo "USERNAME must be set."
	exit 1
fi

if [ -z "${PASSWORD}" ]; then
	echo "PASSWORD must be set."
	exit 1
fi

if [ ! -f /home/${ZEPPELIN_USER}/.ssh/id_rsa ]; then
    
    # If the user provided a private key, copy it to the ssh folder
    if [ -f /ssh/glue.pem ]; then
        su --login "${ZEPPELIN_USER}" --command "mkdir -p /home/${ZEPPELIN_USER}/.ssh"
        cp /ssh/glue.pem /home/${ZEPPELIN_USER}/.ssh/id_rsa
    else  
        #
        # Otherwise, we'll create our own key
        # and the user will need to update the dev
        # endpoint with the public key infom
        #
        su --login "${ZEPPELIN_USER}" --command "ssh-keygen -q -N '' -t rsa -f /home/${ZEPPELIN_USER}/.ssh/id_rsa"
        echo "Add this public key to the dev endpoint and restart the container after you have done this."
        cat /home/"${ZEPPELIN_USER}"/.ssh/id_rsa.pub
        exit 1
    fi

    # Reset permissions
    chown --recursive "${ZEPPELIN_USER}":zeppelin "/home/${ZEPPELIN_USER}"
    chmod 0700 /home/"${ZEPPELIN_USER}"
	chmod 0700 /home/"${ZEPPELIN_USER}"/.ssh
	chmod 0600 /home/"${ZEPPELIN_USER}"/.ssh/*
    chmod 0640 /home/"${ZEPPELIN_USER}"/.ssh/*.pub
fi

PUBLIC_CERT_PATH="/home/${ZEPPELIN_USER}/.ssh/id_rsa.pub"

if [ -f "${PUBLIC_CERT_PATH}" ]; then
    echo "This is public key associated with the locally created private key being used to SSH to the dev endpoint."
    cat "${PUBLIC_CERT_PATH}"
else
    echo "The container is using a user-provided private key, make sure you have provided the public key pair to the dev endpoint."
fi

if [ ! -f "${ZEPPELIN_HOME}/firstrun" ]; then
    # Zeppelin prior to 0.8.0 does not support hashed passwords, and Glue doesn't support
    # 0.8.0 and later
    #HASH=$(java -jar ${SHIRO_HASHER} --algorithm SHA-512 --format shiro1 --iterations 500000 ${PASSWORD})
    sed -i "s|\${USERNAME}|${USERNAME}|" "${ZEPPELIN_HOME}/conf/shiro.ini"
    sed -i "s|\${PASSWORD}|${PASSWORD}|" "${ZEPPELIN_HOME}/conf/shiro.ini"
    touch "${ZEPPELIN_HOME}/firstrun"
fi

echo "Starting SSH connection to dev endpoint."
su --login "${ZEPPELIN_USER}" --command "ssh -o StrictHostKeyChecking=no -i /home/${ZEPPELIN_USER}/.ssh/id_rsa -qvnfNT -L :9007:169.254.76.1:9007 glue@${DEV_ENDPOINT}"

echo "Starting zeppelin notebook."
su --login "${ZEPPELIN_USER}" --command "${ZEPPELIN_HOME}/bin/zeppelin-daemon.sh start"

# Do something in the foreground to keep the container running
# Trap any TERM INT and execute "true"
trap true TERM INT
tail -f /dev/null