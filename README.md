# DBA Administration Scripts

<div align="center">
  
<!-- Badges -->
<p>
  <a href="https://github.com/RezarLO/dba-administration-scripts/graphs/contributors">
    <img src="https://img.shields.io/github/contributors/RezarLO/dba-administration-scripts" alt="contributors" />
  </a>
  <a href="">
    <img src="https://img.shields.io/github/last-commit/RezarLO/dba-administration-scripts" alt="last update" />
  </a>
  <a href="https://github.com/RezarLO/dba-administration-scripts/network/members">
    <img src="https://img.shields.io/github/forks/RezarLO/dba-administration-scripts" alt="forks" />
  </a>
  <a href="https://github.com/RezarLO/dba-administration-scripts/stargazers">
    <img src="https://img.shields.io/github/stars/RezarLO/dba-administration-scripts" alt="stars" />
  </a>
  <a href="https://github.com/RezarLO/dba-administration-scripts/issues/">
    <img src="https://img.shields.io/github/issues/RezarLO/dba-administration-scripts" alt="open issues" />
  </a>
  <a href="https://github.com/RezarLO/dba-administration-scripts/blob/master/LICENSE">
    <img src="https://img.shields.io/github/license/Louis3797/awesome-readme-template.svg" alt="license" />
  </a>
</p>
   
</div>

<br />

A collection of automation and monitoring scripts for database administrators (DBAs).  
These scripts are designed to simplify daily operational tasks, enhance reliability, and provide proactive alerts for database clusters.

---

## 🚀 Current Scripts

### 1. Patroni Leader & Replication Monitor (`patroni_leader_monitor.sh`)
This Bash script monitors a Patroni PostgreSQL cluster for:
- **Leader changes** (detects and logs when a new leader is elected).
- **Leader status changes** (e.g., `running` → `stopped`).
- **Replica replication lag** (alerts if replicas fall behind the leader).
- **Automated alerts** (via `sendSMS.pl` or `sendSMSLEADER.pl`).

It maintains log files and text messages for integration with external notification systems.

---

## ⚙️ Configuration

Update the following variables in the script:

```bash
# Patroni cluster nodes
NODES=("10.253.23.23" "10.253.23.24" "10.253.23.25")
PORT=8008

# File paths
LEADER_FILE="/var/lib/pgsql/scripts/patroni_leader.txt"
STATUS_FILE="/var/lib/pgsql/scripts/patroni_leader_status.txt"
LOG_FILE="/var/lib/pgsql/scripts/patroni_leader_changes.log"
```

## 📊 Output
Logs are stored in:
patroni_leader_changes.log → Leader/status changes and replica lag warnings.

Alerts are sent via SMS scripts:
  - message_leader.txt (leader changes)
  - message_status.txt (status changes)
  - message.txt (replica lag warnings)

## 🛠 Requirements
  - Bash (tested on RHEL8)
  - curl
  - jq (for JSON parsing)
  - Perl (for SMS scripts)

