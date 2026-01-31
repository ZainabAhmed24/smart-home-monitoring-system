#!/bin/bash
# Threshold Check Script for Smart Home Monitoring

# Paths
ALERT_FILE="/root/SmartHomeMonitoring/alerts/alert_log.log"
LAST_RUN_FILE="/root/SmartHomeMonitoring/alerts/last_run.log"
TEMP_FILE="/root/SmartHomeMonitoring/alerts/temp_alert_log.log"

# Thresholds
TEMP_THRESHOLD=27
HUMIDITY_THRESHOLD=40
SOIL_MOISTURE_THRESHOLD=30
CPU_THRESHOLD=90.0
MEM_THRESHOLD=80.0
DISK_THRESHOLD=85  # Percentage
FRIDGE_OPEN_THRESHOLD=60  # 1 minute in seconds
LIGHT_ON_THRESHOLD=$((5 * 3600))  # 5 hours in seconds

# Outlier multipliers
OUTLIER_MULTIPLIER=2.0

# Get the last processed timestamp
if [ -f "$LAST_RUN_FILE" ]; then
    LAST_RUN=$(cat "$LAST_RUN_FILE")
else
    LAST_RUN="1970-01-01 00:00:00"
fi

# Update the last run timestamp
TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")
echo "$TIMESTAMP" > "$LAST_RUN_FILE"

# Function to check if a log entry is new
is_new_entry() {
    LOG_TIMESTAMP=$1
    if [[ "$LOG_TIMESTAMP" > "$LAST_RUN" ]]; then
        return 0  # New entry
    else
        return 1  # Old entry
    fi
}

# Function for outlier detection
is_outlier() {
    VALUE=$1
    MEAN=$2
    STD=$3
    LOWER_BOUND=$(echo "$MEAN - $OUTLIER_MULTIPLIER * $STD" | bc -l)
    UPPER_BOUND=$(echo "$MEAN + $OUTLIER_MULTIPLIER * $STD" | bc -l)
    RESULT=$(echo "$VALUE < $LOWER_BOUND || $VALUE > $UPPER_BOUND" | bc -l)
    return $RESULT
}

# ---- Indoor Climate ----
while IFS= read -r line; do
    LOG_TIMESTAMP=$(echo "$line" | awk -F, '{print $1}')
    TEMP=$(echo "$line" | grep -oP '(?<=Temp: )\d+')
    HUMIDITY=$(echo "$line" | grep -oP '(?<=Humidity: )\d+')

    if is_new_entry "$LOG_TIMESTAMP"; then
        if (( TEMP > TEMP_THRESHOLD )); then
            echo "$LOG_TIMESTAMP ALERT: High indoor temperature ($TEMP°C)" >> "$ALERT_FILE"
        fi
        if (( HUMIDITY < HUMIDITY_THRESHOLD )); then
            echo "$LOG_TIMESTAMP ALERT: Low indoor humidity ($HUMIDITY%)" >> "$ALERT_FILE"
        fi

        # Outlier detection for temperature
        if [ -f "/root/SmartHomeMonitoring/logs/temp_stats.log" ]; then
            MEAN=$(awk '{print $1}' /root/SmartHomeMonitoring/logs/temp_stats.log)
            STD=$(awk '{print $2}' /root/SmartHomeMonitoring/logs/temp_stats.log)
            if is_outlier "$TEMP" "$MEAN" "$STD"; then
                echo "$LOG_TIMESTAMP ALERT: Temperature anomaly detected! Value: $TEMP°C (mean: $MEAN°C, std: $STD°C)" >> "$ALERT_FILE"
            fi
        fi
    fi
done < /root/SmartHomeMonitoring/logs/indoor_climate.log

# ---- Garden ----
while IFS= read -r line; do
    LOG_TIMESTAMP=$(echo "$line" | awk -F, '{print $1}')
    SOIL_MOISTURE=$(echo "$line" | grep -oP '(?<=Soil Moisture: )\d+')

    if is_new_entry "$LOG_TIMESTAMP"; then
        if (( SOIL_MOISTURE < SOIL_MOISTURE_THRESHOLD )); then
            echo "$LOG_TIMESTAMP ALERT: Low soil moisture ($SOIL_MOISTURE%)" >> "$ALERT_FILE"
        fi
    fi
done < /root/SmartHomeMonitoring/logs/garden.log

# ---- System Metrics ----
while IFS= read -r line; do
    LOG_TIMESTAMP=$(echo "$line" | awk -F, '{print $1}')
    CPU_USAGE=$(echo "$line" | grep -oP '(?<=CPU: )\d+\.\d+')
    MEM_USAGE=$(echo "$line" | grep -oP '(?<=Memory: )\d+\.\d+')
    DISK_USAGE=$(echo "$line" | grep -oP '(?<=Disk: )\d+')

    if is_new_entry "$LOG_TIMESTAMP"; then
        if (( $(echo "$CPU_USAGE > $CPU_THRESHOLD" | bc -l) )); then
            echo "$LOG_TIMESTAMP ALERT: High CPU usage ($CPU_USAGE%)" >> "$ALERT_FILE"
        fi
        if (( $(echo "$MEM_USAGE > $MEM_THRESHOLD" | bc -l) )); then
            echo "$LOG_TIMESTAMP ALERT: High memory usage ($MEM_USAGE%)" >> "$ALERT_FILE"
        fi
        if (( DISK_USAGE > DISK_THRESHOLD )); then
            echo "$LOG_TIMESTAMP ALERT: High disk usage ($DISK_USAGE%)" >> "$ALERT_FILE"
        fi
    fi
done < /root/SmartHomeMonitoring/logs/system_metrics.log

# ---- Appliances ----
while IFS= read -r line; do
    LOG_TIMESTAMP=$(echo "$line" | awk -F, '{print $1}')
    FRIDGE_OPEN_TIME=$(echo "$line" | grep -oP '(?<=Fridge Open Time: )\d+')

    if is_new_entry "$LOG_TIMESTAMP" && (( FRIDGE_OPEN_TIME > FRIDGE_OPEN_THRESHOLD )); then
        echo "$LOG_TIMESTAMP ALERT: Fridge left open for more than 1 minute ($FRIDGE_OPEN_TIME seconds)" >> "$ALERT_FILE"
    fi
done < /root/SmartHomeMonitoring/logs/appliance.log

# ---- Lighting ----
while IFS= read -r line; do
    LOG_TIMESTAMP=$(echo "$line" | awk -F, '{print $1}')
    LIGHT_ON_TIME=$(echo "$line" | grep -oP '(?<=Light On Duration: )\d+')

    if is_new_entry "$LOG_TIMESTAMP" && (( LIGHT_ON_TIME > LIGHT_ON_THRESHOLD )); then
        echo "$LOG_TIMESTAMP ALERT: Light left on for more than 5 hours ($LIGHT_ON_TIME seconds)" >> "$ALERT_FILE"
    fi
done < /root/SmartHomeMonitoring/logs/lighting.log

# ---- Security ----
while IFS= read -r line; do
    LOG_TIMESTAMP=$(echo "$line" | awk -F, '{print $1}')
    MOTION=$(echo "$line" | grep -oP '(?<=Motion Detected: )YES')

    if is_new_entry "$LOG_TIMESTAMP" && [ "$MOTION" == "YES" ]; then
        echo "$LOG_TIMESTAMP ALERT: Indoor motion detected!" >> "$ALERT_FILE"
    fi
done < /root/SmartHomeMonitoring/logs/security.log

# ---- Outdoor Security ----
while IFS= read -r line; do
    LOG_TIMESTAMP=$(echo "$line" | awk -F, '{print $1}')
    MOTION=$(echo "$line" | grep -oP '(?<=Outdoor Motion Detected: )YES')

    if is_new_entry "$LOG_TIMESTAMP" && [ "$MOTION" == "YES" ]; then
        echo "$LOG_TIMESTAMP ALERT: Outdoor motion detected!" >> "$ALERT_FILE"
    fi
done < /root/SmartHomeMonitoring/logs/outdoor_security.log

# ---- Weather ----
while IFS= read -r line; do
    LOG_TIMESTAMP=$(echo "$line" | awk -F, '{print $1}')
    RAIN=$(echo "$line" | grep -oP '(?<=Rain: )YES')

    if is_new_entry "$LOG_TIMESTAMP" && [ "$RAIN" == "YES" ]; then
        echo "$LOG_TIMESTAMP ALERT: Rain detected!" >> "$ALERT_FILE"
    fi
done < /root/SmartHomeMonitoring/logs/weather.log

# ---- Camera Status ----
while IFS= read -r line; do
    LOG_TIMESTAMP=$(echo "$line" | awk -F, '{print $1}')
    CAMERA_STATUS=$(echo "$line" | grep -oP '(?<=Indoor Camera Status: )OFFLINE')

    if is_new_entry "$LOG_TIMESTAMP" && [ "$CAMERA_STATUS" == "OFFLINE" ]; then
        echo "$LOG_TIMESTAMP ALERT: Indoor camera offline!" >> "$ALERT_FILE"
    fi
done < /root/SmartHomeMonitoring/logs/indoor_camera.log

# ---- Doorbell ----
while IFS= read -r line; do
    LOG_TIMESTAMP=$(echo "$line" | awk -F, '{print $1}')
    DOORBELL_RING=$(echo "$line" | grep -oP '(?<=Doorbell Ring: )YES')

    if is_new_entry "$LOG_TIMESTAMP" && [ "$DOORBELL_RING" == "YES" ]; then
        echo "$LOG_TIMESTAMP ALERT: Doorbell rang!" >> "$ALERT_FILE"
    fi
done < /root/SmartHomeMonitoring/logs/doorbell.log

# Sort the alert log by timestamp
sort -k1,2 "$ALERT_FILE" > "$TEMP_FILE"
mv "$TEMP_FILE" "$ALERT_FILE"
