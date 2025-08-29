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
    <img src="https://img.shields.io/github/license/RezarLO/dba-administration-scripts.svg" alt="license" />
  </a>
</p>
   
</div>

<br />

A collection of automation and monitoring scripts for database administrators (DBAs).  
These scripts are designed to simplify daily operational tasks, enhance reliability, and provide proactive alerts for database clusters.

---

<!-- Table of Contents -->
# :notebook_with_decorative_cover: Table of Contents

- [About the Project](#star2-about-the-project)
- [Getting Started](#toolbox-getting-started)
  * [Oracle](#bangbang-Oracle)
  * [Postgresql](#gear-Postgresql)
  * [Mysql](#test_tube-Mysql)
  * [Mariadb](#running-Mariadb)
  * [ClickHouse](#triangular_ClickHouse)
  * [Patroni](#tail_Patroni)
- [Contributing](#wave-contributing)
  * [Code of Conduct](#scroll-code-of-conduct)
- [FAQ](#grey_question-faq)
- [License](#warning-license)
- [Contact](#handshake-contact)
- [Acknowledgements](#gem-acknowledgements)



<!-- About the Project -->
## :star2: About the Project
A collection of automation and monitoring scripts for database administrators (DBAs).  
These scripts are designed to simplify daily operational tasks, enhance reliability, and provide proactive alerts for database clusters.


<!-- Oracle -->
### :bangbang: Oracle


<!-- Postgresql -->
### :gear: Postgresql


<!-- Mysql -->
### :test_tube: Mysql


<!-- Mariadb -->
### :running: Mariadb


<!-- ClickHouse -->
### :triangular: ClickHouse


<!-- Patroni -->
### :tail: Patroni



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

