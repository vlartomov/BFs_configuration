#!/bin/bash

# This script is for setting up the necessary packages and configurations

# Exit immediately if a command exits with a non-zero status.
set -e

# for sending mail-reports
echo "================ sending mail-reports ================="
apt-get install -y mutt sendmail

# for correct SITE-definition
echo "================ grepcidr ================="
apt-get install -y grepcidr

# for loading environmental modules
echo "================ environment-modules ================="
apt-get install -y environment-modules

# for MTT running
echo "================ liburi-perl ================="
apt-get install -y liburi-perl

# for ucx-repo building
echo "================ valgrind ================="
NEEDRESTART_MODE=a apt-get install -y valgrind
echo "================ libgfortran5 libgfortran-11-dev ================="
NEEDRESTART_MODE=a apt-get install -y libgfortran5 libgfortran-11-dev
echo "================ autoconf ================="
NEEDRESTART_MODE=a apt-get install -y autoconf
echo "================ automake ================="
apt-get install -y automake
echo "================ autotools-dev ================="
apt-get install -y autotools-dev

# for mpi-small-tests building
echo "================ gfortran ================="
NEEDRESTART_MODE=a apt-get install -y gfortran
echo "================ pdsh ================="
NEEDRESTART_MODE=a apt-get install -y pdsh
echo "================ libreadline-dev ================="
NEEDRESTART_MODE=a apt-get install -y libreadline-dev

# Creating symbolic links for libraries
cd /lib/aarch64-linux-gnu
ln -sf libreadline.so.8.1 libreadline.so.6
ln -sf libhistory.so.8.1 libhistory.so.6
ln -sf libncurses.so.6.3 libncurses.so.5
ln -sf libtinfo.so.6.3 libtinfo.so.5

# Function to update SSH configuration without creating duplicates
update_ssh_config() {
    local key="$1"
    local value="$2"
    local file="/etc/ssh/ssh_config"

    # Check if the exact setting already exists
    if grep -qE "^\s*${key}\s+${value}\s*$" "$file"; then
        echo "${key} is already set to ${value}. No changes made."
        return
    fi

    # Check for the presence of the key regardless of its value/commented state
    local existingLine=$(grep -E "^\s*#?\s*${key}\s+.*$" "$file")
    if [[ ! -z "$existingLine" ]]; then
        # The setting exists but isn't correct; modify it
        sed -i -E "s|^\s*#?\s*${key}\s+.*$|${key} ${value}|" "$file"
        echo "${key} has been updated to ${value}."
    else
        # The setting doesn't exist at all; append it
        echo "${key} ${value}" >> "$file"
        echo "${key} added and set to ${value}."
    fi
}

# Update SSH configuration
update_ssh_config "StrictHostKeyChecking" "no"
update_ssh_config "CheckHostIP" "no"

# Restart SSH service
systemctl restart ssh

