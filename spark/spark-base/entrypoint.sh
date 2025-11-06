#!/bin/bash

# Set up SSH authorized_keys
mkdir -p /root/.ssh
chmod 700 /root/.ssh

# If SSH public key is mounted or provided via volume, use it
if [ -f /tmp/authorized_keys ]; then
    cp /tmp/authorized_keys /root/.ssh/authorized_keys
    chmod 600 /root/.ssh/authorized_keys
    echo "SSH public key copied from /tmp/authorized_keys"
# If SSH_PUBLIC_KEY environment variable is set, use it
elif [ -n "$SSH_PUBLIC_KEY" ]; then
    echo "$SSH_PUBLIC_KEY" > /root/.ssh/authorized_keys
    chmod 600 /root/.ssh/authorized_keys
    echo "SSH public key set from environment variable"
# Otherwise, create empty authorized_keys to allow password auth
else
    touch /root/.ssh/authorized_keys
    chmod 600 /root/.ssh/authorized_keys
    echo "No SSH key provided, password authentication enabled"
fi

# Start SSH server in the background
echo "Starting SSH server..."
mkdir -p /var/run/sshd
/usr/sbin/sshd

function wait_for_it()
{
    local serviceport=$1
    local service=${serviceport%%:*}
    local port=${serviceport#*:}
    local retry_seconds=5
    local max_try=100
    let i=1

    nc -z $service $port
    result=$?

    until [ $result -eq 0 ]; do
      echo "[$i/$max_try] check for ${service}:${port}..."
      echo "[$i/$max_try] ${service}:${port} is not available yet"
      if (( $i == $max_try )); then
        echo "[$i/$max_try] ${service}:${port} is still not available; giving up after ${max_try} tries. :/"
        exit 1
      fi

      echo "[$i/$max_try] try in ${retry_seconds}s once again ..."
      let "i++"
      sleep $retry_seconds

      nc -z $service $port
      result=$?
    done
    echo "[$i/$max_try] $service:${port} is available."
}

for i in ${SERVICE_PRECONDITION[@]}
do
    wait_for_it ${i}
done

exec $@

