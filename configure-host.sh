#!/bin/bash

# Initialize variables
VERBOSE=false
HOSTNAME=""
IPADDRESS=""
HOSTENTRY_NAME=""
HOSTENTRY_IP=""

# Function to print messages in verbose mode
log_verbose() {
    if [ "$VERBOSE" = true ]; then
        echo "$1"
    fi
}

# Function to change the hostname
update_hostname() {
    local desired_hostname="$1"
    local current_hostname=$(hostname)

    if [ "$desired_hostname" != "$current_hostname" ]; then
        echo "$desired_hostname" > /etc/hostname
        hostname "$desired_hostname"
        log_verbose "Hostname changed to $desired_hostname"
        logger "Hostname changed from $current_hostname to $desired_hostname"
    else
        log_verbose "Hostname is already set to $desired_hostname"
    fi
}

# Function to update /etc/hosts
update_hosts() {
    local entry_name="$1"
    local entry_ip="$2"

    if ! grep -q "$entry_ip $entry_name" /etc/hosts; then
        echo "$entry_ip $entry_name" >> /etc/hosts
        log_verbose "Added $entry_name with IP $entry_ip to /etc/hosts"
        logger "Added $entry_name with IP $entry_ip to /etc/hosts"
    else
        log_verbose "$entry_name with IP $entry_ip already exists in /etc/hosts"
    fi
}

# Function to update the IP address (Example uses netplan, adjust for your system)
update_ip() {
    local desired_ip="$1"
    # This is a placeholder for IP address update logic, which varies by system.
    # You would typically modify a netplan YAML file or similar, then apply the changes.
    log_verbose "IP address update logic goes here"
    logger "IP address changed to $desired_ip"
}

# Ignore SIGTERM, SIGHUP, SIGINT
trap '' TERM HUP INT

# Parse command-line options
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -verbose) VERBOSE=true ;;
        -name) HOSTNAME="$2"; shift ;;
        -ip) IPADDRESS="$2"; shift ;;
        -hostentry) HOSTENTRY_NAME="$2"; HOSTENTRY_IP="$3"; shift 2 ;;
        *) echo "Unknown parameter passed: $1"; exit 1 ;;
    esac
    shift
done

# Apply the configurations
if [ -n "$HOSTNAME" ]; then
    update_hostname "$HOSTNAME"
fi

if [ -n "$IPADDRESS" ]; then
    update_ip "$IPADDRESS"
fi

if [ -n "$HOSTENTRY_NAME" ] && [ -n "$HOSTENTRY_IP" ]; then
    update_hosts "$HOSTENTRY_NAME" "$HOSTENTRY_IP"
fi
