#!/bin/bash

SYSLOG_SERVER="127.0.0.1"
SYSLOG_PORT=514
FACILITY=1
MESSAGE_COUNT=10
HOSTNAME=$(hostname)

send_syslog() {
    local program="$1"
    local severity="$2"
    local message="$3"

    priority=$((FACILITY * 8 + severity))
    timestamp=$(date +"%b %d %H:%M:%S")

    syslog_msg="<$priority>$timestamp $HOSTNAME $program: $message"

    echo "SEND -> $syslog_msg"

    echo -n "$syslog_msg" | nc -u -w1 "$SYSLOG_SERVER" "$SYSLOG_PORT"
}

logs_program=("kernel" "alert" "crit" "app" "disk" "service" "login" "debug")
logs_severity=(0 1 2 3 4 5 6 7)
logs_message=(
    "System unusable"
    "Immediate action required"
    "Critical condition"
    "Application error"
    "Disk space warning"
    "Service notice"
    "User login successful"
    "Debug trace message"
)

echo "=== SYSLOG TESZT INDUL ==="

for ((i=1; i<=MESSAGE_COUNT; i++)); do
    idx=$((RANDOM % ${#logs_program[@]}))

    send_syslog \
        "${logs_program[$idx]}" \
        "${logs_severity[$idx]}" \
        "${logs_message[$idx]}"

    sleep 1
done

echo "=== KÉSZ ==="
