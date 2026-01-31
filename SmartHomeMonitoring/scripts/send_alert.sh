#!/bin/bash
# Alert Sending Script

ALERT_FILE="/root/SmartHomeMonitoring/alerts/alert_log.log"
LAST_EMAILED_FILE="/root/SmartHomeMonitoring/alerts/last_emailed.log"
SLACK_WEBHOOK_URL="https://hooks.slack.com/services/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"

# Get the last emailed timestamp
if [ -f "$LAST_EMAILED_FILE" ]; then
    LAST_EMAILED=$(cat "$LAST_EMAILED_FILE")
else
    LAST_EMAILED="1970-01-01 00:00:00"
fi

# Find new alerts since last emailed and number them
NEW_ALERTS=$(awk -v last="$LAST_EMAILED" '$0 > last {print}' "$ALERT_FILE" | nl)

# Update the last emailed timestamp
TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")
echo "$TIMESTAMP" > "$LAST_EMAILED_FILE"

# Send email if there are new alerts
if [ -n "$NEW_ALERTS" ]; then
    # Email formatting
    EMAIL_BODY=$(echo -e "Subject: New Smart Home Alerts\n\nSmart Home Monitoring Alerts:\n\n$NEW_ALERTS")
    echo "$EMAIL_BODY" | sendmail root@MSI.localdomain

    echo "New alerts sent via email."

    # Send Slack notification if there are new alerts
    SLACK_MESSAGE=$(echo -e "Smart Home Monitoring Alerts:\n\n$NEW_ALERTS")
    curl -X POST -H 'Content-type: application/json' \
        --data "{\"text\":\"$SLACK_MESSAGE\"}" "$SLACK_WEBHOOK_URL" >/dev/null 2>&1
    echo "New alerts sent to Slack."
else
    echo "No new alerts to send."
fi
