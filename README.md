# Smart Home Monitor  
### Monitoring + Alerting System (Bash + Python)

Smart Home Monitor is a **monitoring and alerting system** that centralizes simulated smart-home data collection, detects threshold breaches/anomalies, and automatically notifies users. It continuously monitors **appliances/devices, system resource usage, and security-style events**, then logs activity and triggers alerts when needed. :contentReference[oaicite:5]{index=5}

---

## What it does

- **Collects data automatically** (simulated sensor + device logs)
- **Checks thresholds + detects anomalies**
  - Threshold comparison (ex: temperature/humidity)
  - Outlier detection using basic statistics (mean + standard deviation) :contentReference[oaicite:6]{index=6}
- **Generates alerts** into a centralized alert log
- **Sends notifications**
  - Email via `sendmail` (or optional `mutt`)
  - Slack notifications via webhook + `curl` :contentReference[oaicite:7]{index=7}
- Optional **Python GUI** for demo/testing:
  - View alerts
  - View logs
  - Send test email + Slack notifications :contentReference[oaicite:8]{index=8}

---

## System Architecture (High Level)

This project is built around 3 automated stages (scheduled via cron): :contentReference[oaicite:9]{index=9}

1. **Data Collection (`data_collection.sh`)**  
   Writes simulated readings into log files (ex: indoor climate, garden, system metrics) and records security/activity-style events. Runs every **2 minutes**. :contentReference[oaicite:10]{index=10}  

2. **Threshold + Anomaly Check (`threshold_check.sh`)**  
   Reads logs, compares against thresholds, detects anomalies, and writes alerts to `alerts/alert_log.log`. Updates `alerts/last_run.log`. Runs every **4 minutes**. :contentReference[oaicite:11]{index=11}  

3. **Alert Sender (`send_alert.sh`)**  
   Looks for new alerts since last notification, then sends email + Slack. Updates `alerts/last_emailed.log`. Runs every **6 minutes**. :contentReference[oaicite:12]{index=12}  

Optional: **GUI (`gui.py`)** for demonstration/testing. :contentReference[oaicite:13]{index=13}

---

## Directory Structure

The system is organized into three main folders: **scripts**, **logs**, and **alerts**. :contentReference[oaicite:14]{index=14}

```text
/root/SmartHomeMonitoring
├── scripts/
│   ├── data_collection.sh
│   ├── threshold_check.sh
│   ├── send_alert.sh
│   ├── view_recent_alerts.sh
│   └── gui.py
├── logs/
│   ├── indoor_climate.log
│   ├── garden.log
│   ├── system_metrics.log
│   └── ...
└── alerts/
    ├── alert_log.log
    ├── last_run.log
    └── last_emailed.log
