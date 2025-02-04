#
# Copyright (c) 2024 Wind River Systems, Inc.
#
# SPDX-License-Identifier: Apache-2.0
#

#!/bin/bash

# Check if running as root and configure umask for root
if [ "$(id -u)" -eq 0 ]; then
    # Ensure /root/.bashrc exists and contains the umask setting
    if [ ! -f /root/.bashrc ]; then
        echo "umask 027" > /root/.bashrc
        chmod 600 /root/.bashrc
    elif ! grep -q "umask 027" /root/.bashrc; then
        echo "umask 027" >> /root/.bashrc
    fi

    # Ensure /root/.bash_profile exists and contains the umask setting
    if [ ! -f /root/.bash_profile ]; then
        echo "umask 027" > /root/.bash_profile
        chmod 600 /root/.bash_profile
    elif ! grep -q "umask 027" /root/.bash_profile; then
        echo "umask 027" >> /root/.bash_profile
    fi

    # Set permissions for both files
    chmod 600 /root/.bashrc 2>/dev/null || {
        logger -p user.err "ERROR: Failed to set permissions to 600 for /root/.bashrc"
    }
    chmod 600 /root/.bash_profile 2>/dev/null || {
        logger -p user.err "ERROR: Failed to set permissions to 600 for /root/.bash_profile"
    }
fi
