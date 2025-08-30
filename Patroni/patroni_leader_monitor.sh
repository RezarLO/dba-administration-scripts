#!/bin/bash

# Config: list your Patroni nodes
NODES=("10.253.23.23" "10.253.23.24" "10.253.23.25")
PORT=8008

# Files
LEADER_FILE="/var/lib/pgsql/scripts/patroni_leader.txt"
STATUS_FILE="/var/lib/pgsql/scripts/patroni_leader_status.txt"
LOG_FILE="/var/lib/pgsql/scripts/patroni_leader_changes.log"

# Try to find the current leader and its status
for node in "${NODES[@]}"; do
    cluster_info=$(curl -s "http://$node:$PORT/cluster")
    leader=$(echo "$cluster_info" | jq -r '.members[] | select(.role == "leader") | .name')
    leader_status=$(echo "$cluster_info" | jq -r '.members[] | select(.role == "leader") | .state')

    if [[ "$leader" != "null" && -n "$leader" ]]; then
        break
    fi
done

# If no leader found
if [[ -z "$leader" || "$leader" == "null" ]]; then
    echo "$(date '+%F %T') ERROR: Could not determine leader from any node" >> "$LOG_FILE"
    exit 1
fi

# Initialize if files don't exist
if [[ ! -f "$LEADER_FILE" ]]; then
    echo "$leader" > "$LEADER_FILE"
    echo "$leader_status" > "$STATUS_FILE"
    echo "$(date '+%F %T') Initial leader: $leader with status: $leader_status" >> "$LOG_FILE"
    exit 0
fi

# Read stored leader and status
stored_leader=$(cat "$LEADER_FILE")
stored_status=$(cat "$STATUS_FILE")

# Compare and act on leader change
if [[ "$leader" != "$stored_leader" ]]; then
    echo "$leader" > "$LEADER_FILE"
    echo "$leader_status" > "$STATUS_FILE"
    echo "Change in leader at CLUSTER1 and new Leader is : $leader" > /var/lib/pgsql/scripts/message_leader.txt
    /var/lib/pgsql/scripts/sendSMSLEADER.pl
    echo "$(date '+%F %T') Leader changed: $stored_leader → $leader (Status: $leader_status)" >> "$LOG_FILE"
else
    # Leader is the same — check if status changed
    if [[ "$leader_status" != "$stored_status" ]]; then
        echo "$leader_status" > "$STATUS_FILE"
        echo "Leader $leader status changed: $stored_status → $leader_status" > /var/lib/pgsql/scripts/message_status.txt
        /var/lib/pgsql/scripts/sendSMS.pl
        echo "$(date '+%F %T') Leader status changed: $stored_status → $leader_status" >> "$LOG_FILE"
    fi
fi

# Replication lag check
replica_lags=$(curl -s "http://$node:$PORT/cluster" | jq -c '.members[] | select(.role != "leader") | {name: .name, lag: .lag}')

while IFS= read -r replica; do
    name=$(echo "$replica" | jq -r '.name')
    lag=$(echo "$replica" | jq -r '.lag')

    # Some versions may have lag = null
    if [[ "$lag" == "null" || -z "$lag" ]]; then
        lag=0
    fi

    if (( lag > 0 )); then
        echo "$(date '+%F %T') WARNING: Replica '$name' lag is $lag bytes" >> "$LOG_FILE"
        echo "WARNING: Replica $name lag is $lag bytes" > /var/lib/pgsql/scripts/message.txt
        /var/lib/pgsql/scripts/sendSMS.pl
    fi

done <<< "$replica_lags"