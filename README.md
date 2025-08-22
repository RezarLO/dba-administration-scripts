# DBA Administration Scripts

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
