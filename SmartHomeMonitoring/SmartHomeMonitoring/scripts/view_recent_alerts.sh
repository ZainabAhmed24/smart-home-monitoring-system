#!/bin/bash
# Script to view alerts from the last 20 minutes

ALERT_LOG="/root/SmartHomeMonitoring/alerts/alert_log.log"  # Path to the alert log
TIME_WINDOW="-20 min"  # Time window to look back

# Check if the alert log exists
if [ -f "$ALERT_LOG" ]; then
    echo "Alerts from the last 20 minutes:"
    awk -v now="$(date +"%Y-%m-%d %H:%M:%S" -d "$TIME_WINDOW")" '$0 >= now' "$ALERT_LOG"
else
    echo "Alert log file not found: $ALERT_LOG"
fi
