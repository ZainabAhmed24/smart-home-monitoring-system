# Smart Home Monitor  
### Monitoring & Alerting System (Bash + Python)

Smart Home Monitor is a **monitoring and alerting system** that centralizes simulated smart-home data collection, detects threshold breaches and anomalies, and automatically notifies users.  
It continuously monitors **appliances/devices, system resource usage, and security-style events**, logs activity, and triggers alerts when required.

---

## What It Does

- **Automatically collects data**
  - Simulated sensor readings and device/system logs

- **Checks thresholds & detects anomalies**
  - Threshold comparisons (e.g., temperature, humidity)
  - Outlier detection using basic statistics (mean & standard deviation)

- **Generates alerts**
  - Centralized alert logging for detected issues

- **Sends notifications**
  - Email alerts via `sendmail` (or optional `mutt`)
  - Slack notifications using webhooks and `curl`

- **Optional Python GUI (demo/testing)**
  - View alerts
  - View logs
  - Send test email and Slack notifications

---

## System Architecture (High Level)

The system operates through **three automated stages**, scheduled using **cron jobs**:

### 1️ Data Collection (`data_collection.sh`)
- Writes simulated readings to log files (indoor climate, garden, system metrics)
- Records security and activity-style events  
- Runs every **2 minutes**

### 2 Threshold & Anomaly Check (`threshold_check.sh`)
- Reads logs and compares values against defined thresholds
- Detects anomalies
- Writes alerts to `alerts/alert_log.log`
- Updates `alerts/last_run.log`  
- Runs every **4 minutes**

### 2 Alert Sender (`send_alert.sh`)
- Sends notifications for new alerts
- Email + Slack integration
- Updates `alerts/last_emailed.log`  
- Runs every **6 minutes**

 Optional: **Python GUI (`gui.py`)** for testing and demonstration.

---

## Directory Structure

The system is organized into three main directories:

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
````

> **Note:** Log and alert files are generated automatically while the system runs.

---

## Prerequisites

* **Bash** 4.0+
* **Python** 3.6+

### Python Libraries

* `tkinter`
* `os`
* `subprocess`
* `ttk`

### Tools

* `sendmail` – email notifications
* `curl` – Slack webhook notifications
* `mutt` (optional) – terminal-based email testing

---

## Installation (Ubuntu-Based Systems)

```bash
sudo apt update
sudo apt install python3 python3-tk sendmail curl mutt
```

---

## Setup (Linux / Ubuntu)

### Create Required Directories

```bash
mkdir -p /root/SmartHomeMonitoring/{scripts,alerts,logs}
```

### Make Scripts Executable

```bash
chmod +x /root/SmartHomeMonitoring/scripts/*.sh
```

### Test Email Service

```bash
echo "Test Email" | sendmail root@localhost
```

 **Slack Setup:**
Configure your Slack webhook URL inside the alert sender script or via an environment variable.

---

## Automation (Cron Jobs)

Open the root crontab:

```bash
sudo crontab -e
```

Add the following entries:

```cron
*/2 * * * * /root/SmartHomeMonitoring/scripts/data_collection.sh
*/4 * * * * /root/SmartHomeMonitoring/scripts/threshold_check.sh
*/6 * * * * /root/SmartHomeMonitoring/scripts/send_alert.sh
```

* Data collection → every **2 minutes**
* Threshold check → every **4 minutes**
* Alert sending → every **6 minutes**

---

## Usage

### Run GUI (Demo / Testing)

```bash
python3 /root/SmartHomeMonitoring/scripts/gui.py
```

**Demo Login**

* Username: `admin`
* Password: `1234`

---

### Run Scripts Manually

#### View Recent Alerts

```bash
./view_recent_alerts.sh
```

Displays alerts from the last ~20 minutes.

#### Collect Data

```bash
./data_collection.sh
```

#### Check Thresholds

```bash
./threshold_check.sh
```

#### Send Alerts

```bash
./send_alert.sh
```

#### Test Slack Webhook

```bash
curl -X POST -H 'Content-type: application/json' \
--data '{"text":"Test Slack message"}' <webhook_url>
```

---

## Testing

### Manual Testing

* Run `data_collection.sh` to generate logs
* Modify thresholds or log values to trigger alerts
* Use GUI buttons or scripts to test notifications

### Automated Testing (Cron)

* Confirms logs are generated correctly
* Verifies threshold breaches produce alerts
* Ensures email and Slack notifications are delivered

---

## 🏁 Summary

Smart Home Monitor demonstrates **systems programming concepts** including automation, scripting, logging, monitoring, and alerting using Linux tools.
It combines **Bash scripting**, **Python**, **cron scheduling**, and **notification services** to create a realistic and extensible monitoring system.
