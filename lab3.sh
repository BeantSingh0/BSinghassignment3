#!/bin/bash

# Configuration for the remote servers
SERVER1="remoteadmin@server1-mgmt"
SERVER2="remoteadmin@server2-mgmt"

# Path to the configure-host.sh script
CONFIG_SCRIPT="./configure-host.sh"

# Verbose mode flag
VERBOSE=""

# Function to execute a command with error checking
execute() {
    local command=$1
    echo "Executing: $command"
    eval $command

    if [ $? -ne 0 ]; then
        echo "Error executing command: $command"
        exit 1
    fi
}

# Parse command-line options
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -verbose) VERBOSE="-verbose" ;;
        *) echo "Unknown parameter passed: $1"; exit 1 ;;
    esac
    shift
done

# Securely copy configure-host.sh to each server and execute it
# Configure SERVER1
execute "scp $CONFIG_SCRIPT $SERVER1:/root/"
execute "ssh $SERVER1 'bash /root/$(basename $CONFIG_SCRIPT) $VERBOSE -name loghost -ip 192.168.16.3 -hostentry webhost 192.168.16.4'"

# Configure SERVER2
execute "scp $CONFIG_SCRIPT $SERVER2:/root/"
execute "ssh $SERVER2 'bash /root/$(basename $CONFIG_SCRIPT) $VERBOSE -name webhost -ip 192.168.16.4 -hostentry loghost 192.168.16.3'"

# Update the local /etc/hosts file if necessary
# Note: The implementation of this step is dependent on your specific requirements.
# It could involve calling `configure-host.sh` locally with appropriate arguments.

echo "Configuration of servers completed successfully."
