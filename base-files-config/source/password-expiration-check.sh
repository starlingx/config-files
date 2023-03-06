#
# Copyright (c) 2023 Wind River Systems, Inc.
#
# SPDX-License-Identifier: Apache-2.0
#
# Checks for password expiration for LDAP users, showing warning
# messages for passwords about to expire and prompting users to change
# their password when the password is already expired.
#

USER=$(whoami)
BASE='ou=people,dc=cgcs,dc=local'
SECONDS_IN_A_DAY=86400
LDAP_USER_OUTPUT=$(ldapsearch -x -b "$BASE" "(cn=${USER})")

# Check if the current user is an LDAP user
IS_LDAP_USER=$(echo "$LDAP_USER_OUTPUT" | grep -c "objectClass: account")
if [[ $IS_LDAP_USER -gt 0 ]]; then
    # Get the number of days before password expiration that a warning msg is displayed
    PWD_WARNING_DAYS=$(echo "$LDAP_USER_OUTPUT" | grep shadowWarning | awk '{print $2}')
    # Get the maximum number of days a password can be used before it expires
    PWD_MAX_DAYS=$(echo "$LDAP_USER_OUTPUT" | grep shadowMax | awk '{print $2}')

    # Get the date the password was last changed
    PWD_LAST_CHANGE_DATE=$(ldapsearch -x -b "$BASE" "(cn=${USER})" + \
    | grep pwdChangedTime | awk '{print $2}')

    # Convert from ASN.1 generalizedTime to ISO 8601 format for easier manipulation
    PWD_LAST_CHANGE_DATE=$(echo "$PWD_LAST_CHANGE_DATE" \
    | sed -r 's/([0-9]{4})([0-9]{2})([0-9]{2})([0-9]{2})([0-9]{2})([0-9]{2})(Z)/\1-\2-\3T\4:\5:\6\7/g')

    # Convert the password change date to epoch time
    PWD_LAST_CHANGE_DATE_EPOCH=$(date -d "$PWD_LAST_CHANGE_DATE" +%s)

    # Calculate the number of days between the current date and the password change date
    TODAY_EPOCH_IN_DAYS=$(( $(date +%s) / $SECONDS_IN_A_DAY ))
    PWD_LAST_CHANGE_DATE_EPOCH_IN_DAYS=$(($PWD_LAST_CHANGE_DATE_EPOCH / $SECONDS_IN_A_DAY ))
    DAYS_DIFFERENCE=`expr $TODAY_EPOCH_IN_DAYS - $PWD_LAST_CHANGE_DATE_EPOCH_IN_DAYS`

    # Calculate the number of days remaining until the password expires
    DAYS_REMAINING=`expr $PWD_MAX_DAYS - $DAYS_DIFFERENCE`

    # Display a warning message if the password has already expired and prompts for password change
    if [ "$DAYS_REMAINING" -lt 0 ]; then
        echo "WARNING: Your password has expired."
        echo "You must change your password now and login again!"
        sleep 1
        echo "Changing password for ${USER}."
        passwd
        exit 0
    # Display a warning message if the password will expire soon
    elif [ "$DAYS_REMAINING" -lt ${PWD_WARNING_DAYS} ]; then
        DAY_NOUN="days"
        if [ "$DAYS_REMAINING" -lt 2 ]; then
            DAY_NOUN="day"
        fi
        echo "Warning: The password for ${USER} will expire in ${DAYS_REMAINING} ${DAY_NOUN}."
    fi
fi
