#!/bin/bash
#
# check-faillock.sh - Display lockout status with remaining time
#
# This script is called by pam_exec.so before pam_faillock.so preauth.
# It checks whether the user's account is locked and, if so, displays
# a message with the actual remaining lockout time.
#
# This is needed because sudo passes PAM_SILENT to pam_authenticate(),
# which suppresses pam_faillock's built-in informational messages.
# Using pam_exec.so with the 'stdout' option bypasses this suppression
# by writing directly to the terminal.
#

# PAM_USER is exported by pam_exec as an environment variable
if [ -z "$PAM_USER" ]; then
    exit 0
fi

# Read faillock configuration
DENY=5
UNLOCK_TIME=900
FAIL_INTERVAL=900
FAILLOCK_CONF="/etc/security/faillock.conf"

if [ -f "$FAILLOCK_CONF" ]; then
    val=$(grep -E '^\s*deny\s*=' "$FAILLOCK_CONF" | tail -1 | sed 's/.*=\s*//' | tr -d ' ')
    [ -n "$val" ] && DENY=$val

    val=$(grep -E '^\s*unlock_time\s*=' "$FAILLOCK_CONF" | tail -1 | sed 's/.*=\s*//' | tr -d ' ')
    [ -n "$val" ] && UNLOCK_TIME=$val

    val=$(grep -E '^\s*fail_interval\s*=' "$FAILLOCK_CONF" | tail -1 | sed 's/.*=\s*//' | tr -d ' ')
    [ -n "$val" ] && FAIL_INTERVAL=$val
fi

# If unlock_time is 0, the account is locked permanently until admin resets
# In that case we can't show a countdown
if [ "$UNLOCK_TIME" -eq 0 ] 2>/dev/null; then
    # Count valid failures
    FAIL_COUNT=$(faillock --user "$PAM_USER" 2>/dev/null | awk 'NR>1 && $(NF)=="V" {count++} END {print count+0}')
    if [ "$FAIL_COUNT" -ge "$DENY" ]; then
        echo "Account locked due to $FAIL_COUNT failed login attempts."
        echo "Contact an administrator to unlock your account."
    fi
    exit 0
fi

# Get the most recent valid failure timestamp
# faillock output format:
#   username:
#   When                Type  Source        Valid
#   2026-07-08 10:00:01 TTY   /dev/pts/1    V
#
FAILLOCK_OUTPUT=$(faillock --user "$PAM_USER" 2>/dev/null)

# Count valid failures
FAIL_COUNT=$(echo "$FAILLOCK_OUTPUT" | awk 'NR>2 && $(NF)=="V" {count++} END {print count+0}')

if [ "$FAIL_COUNT" -lt "$DENY" ]; then
    # Account is not locked
    exit 0
fi

# Get the timestamp of the most recent valid failure
# The "When" column is in format "YYYY-MM-DD HH:MM:SS"
LAST_FAILURE=$(echo "$FAILLOCK_OUTPUT" | awk '$(NF)=="V" {timestamp=$1" "$2} END {print timestamp}')

if [ -z "$LAST_FAILURE" ]; then
    # Couldn't parse the timestamp, show generic message
    echo "Account locked due to $FAIL_COUNT failed login attempts."
    MINUTES=$((UNLOCK_TIME / 60))
    echo "Please wait up to $MINUTES minutes or contact an administrator."
    exit 0
fi

# Convert the last failure timestamp to epoch seconds
LAST_EPOCH=$(date -d "$LAST_FAILURE" +%s 2>/dev/null)

if [ -z "$LAST_EPOCH" ]; then
    # date parsing failed, show generic message
    echo "Account locked due to $FAIL_COUNT failed login attempts."
    MINUTES=$((UNLOCK_TIME / 60))
    echo "Please wait up to $MINUTES minutes or contact an administrator."
    exit 0
fi

# Calculate when the lock expires and the remaining time
NOW_EPOCH=$(date +%s)
UNLOCK_EPOCH=$((LAST_EPOCH + UNLOCK_TIME))
REMAINING=$((UNLOCK_EPOCH - NOW_EPOCH))

if [ "$REMAINING" -le 0 ]; then
    # Lock should have already expired, pam_faillock will handle it
    exit 0
fi

# Format the remaining time in a human-friendly way
if [ "$REMAINING" -ge 120 ]; then
    REMAINING_MIN=$(( (REMAINING + 59) / 60 ))  # Round up
    TIME_MSG="$REMAINING_MIN minutes"
elif [ "$REMAINING" -ge 60 ]; then
    REMAINING_SEC=$((REMAINING - 60))
    TIME_MSG="1 minute and $REMAINING_SEC seconds"
else
    TIME_MSG="$REMAINING seconds"
fi

echo "Account locked due to $FAIL_COUNT failed login attempts."
echo "Try again in $TIME_MSG."

exit 0
