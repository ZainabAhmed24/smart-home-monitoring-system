#!/bin/bash
# Collect data from various smart home sensors with enhanced error handling

LOG_DIR="/root/SmartHomeMonitoring/logs"  # Absolute path to logs directory

# Function to log errors to a dedicated error log
log_error() {
    local message=$1
    echo "$(date +"%Y-%m-%d %H:%M:%S") ERROR: $message" >> "$LOG_DIR/error.log"
}

# Create logs directory
if ! mkdir -p "$LOG_DIR"; then
    log_error "Failed to create or access log directory: $LOG_DIR"
    echo "Error: Failed to create log directory. Check permissions." >&2
    exit 1
fi

# Function to safely write to a log file
safe_write() {
    local log_file=$1
    local data=$2
    if ! echo "$data" >> "$log_file"; then
        log_error "Failed to write to $log_file"
        echo "Error: Failed to write to $log_file. Check disk space or permissions." >&2
        exit 2
    fi
}

TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")

# System Metrics
CPU=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1)
MEMORY=$(free | grep Mem | awk '{print $3/$2 * 100.0}')
DISK=$(df / | tail -1 | awk '{print $5}' | sed 's/%//')

CPU=${CPU:-0}
MEMORY=${MEMORY:-0.0}
DISK=${DISK:-0}

safe_write "$LOG_DIR/system_metrics.log" "$TIMESTAMP, CPU: $CPU%, Memory: $MEMORY%, Disk: $DISK%"

# Indoor Climate
TEMP=$((20 + RANDOM % 10))
if (( TEMP > 25 )); then
    HUMIDITY=$((30 + RANDOM % 30))
else
    HUMIDITY=$((50 + RANDOM % 40))
fi

safe_write "$LOG_DIR/indoor_climate.log" "$TIMESTAMP, Indoor Temp: $TEMP°C, Humidity: $HUMIDITY%"

# Garden
RAIN_STATUS=$(if (( RANDOM % 2 )); then echo "YES"; else echo "NO"; fi)
if [[ "$RAIN_STATUS" == "YES" ]]; then
    SOIL_MOISTURE=$((60 + RANDOM % 30))
else
    SOIL_MOISTURE=$((20 + RANDOM % 50))
fi
LIGHT_LEVEL=$((200 + RANDOM % 800))

safe_write "$LOG_DIR/garden.log" "$TIMESTAMP, Soil Moisture: $SOIL_MOISTURE%, Light Level: $LIGHT_LEVEL"

# Appliances
if (( RANDOM % 4 == 0 )); then
    FRIDGE_OPEN_TIME=$((60 + RANDOM % 120))
else
    FRIDGE_OPEN_TIME=$((RANDOM % 60))
fi

safe_write "$LOG_DIR/appliance.log" "$TIMESTAMP, Fridge Open Time: $FRIDGE_OPEN_TIME seconds"

# Lighting
if (( RANDOM % 3 == 0 )); then
    LIGHT_ON_TIME=$((5 * 3600 + RANDOM % 10000))
else
    LIGHT_ON_TIME=$((RANDOM % 3600))
fi

safe_write "$LOG_DIR/lighting.log" "$TIMESTAMP, Light On Duration: $LIGHT_ON_TIME seconds"

# Security
INDOOR_MOTION=$(if (( RANDOM % 2 == 0 )); then echo "YES"; else echo "NO"; fi)
OUTDOOR_MOTION=$(if (( RANDOM % 2 == 0 )); then echo "YES"; else echo "NO"; fi)

safe_write "$LOG_DIR/security.log" "$TIMESTAMP, Indoor Motion Detected: $INDOOR_MOTION"
safe_write "$LOG_DIR/outdoor_security.log" "$TIMESTAMP, Outdoor Motion Detected: $OUTDOOR_MOTION"

# Weather
OUTDOOR_TEMP=$((15 + RANDOM % 10))

safe_write "$LOG_DIR/weather.log" "$TIMESTAMP, Outdoor Temp: $OUTDOOR_TEMP°C, Rain: $RAIN_STATUS"

# Outdoor Lighting
FLOODLIGHT_STATUS=$(if (( RANDOM % 2 )); then echo "ON"; else echo "OFF"; fi)

safe_write "$LOG_DIR/outdoor_lighting.log" "$TIMESTAMP, Floodlight: $FLOODLIGHT_STATUS"

# Indoor Camera
CAMERA_STATUS=$(if (( RANDOM % 2 )); then echo "ONLINE"; else echo "OFFLINE"; fi)

safe_write "$LOG_DIR/indoor_camera.log" "$TIMESTAMP, Indoor Camera Status: $CAMERA_STATUS"

# Doorbell
DOORBELL_RING=$(if (( RANDOM % 2 )); then echo "YES"; else echo "NO"; fi)

safe_write "$LOG_DIR/doorbell.log" "$TIMESTAMP, Doorbell Ring: $DOORBELL_RING"

echo "Data collection completed successfully."
exit 0
