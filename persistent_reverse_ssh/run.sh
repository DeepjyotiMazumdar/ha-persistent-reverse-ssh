#!/usr/bin/env bash
set -e

CONFIG_DIR=/data/options.json
OPTIONS_FILE=/data/options.json

log() { echo "[persistent_reverse_ssh] $*"; }

# Read options from HA add-on options file (the supervisor mounts it at /data/options.json)
if [ ! -f "$OPTIONS_FILE" ]; then
    log "ERROR: options.json not found at $OPTIONS_FILE"
    exit 1
fi

REMOTE_HOST=$(jq -r '.remote_host' "$OPTIONS_FILE")
REMOTE_USER=$(jq -r '.remote_user' "$OPTIONS_FILE")
REMOTE_SSH_PORT=$(jq -r '.remote_ssh_port' "$OPTIONS_FILE")
REMOTE_LISTEN_PORT=$(jq -r '.remote_listen_port' "$OPTIONS_FILE")
LOCAL_TARGET_HOST=$(jq -r '.local_target_host' "$OPTIONS_FILE")
LOCAL_TARGET_PORT=$(jq -r '.local_target_port' "$OPTIONS_FILE")
GATEWAY_PORTS=$(jq -r '.gateway_ports' "$OPTIONS_FILE")
SERVER_ALIVE_INTERVAL=$(jq -r '.server_alive_interval' "$OPTIONS_FILE")
SERVER_ALIVE_COUNT_MAX=$(jq -r '.server_alive_count_max' "$OPTIONS_FILE")
AUTOSSH_MONITOR_PORT=$(jq -r '.autossh_monitor_port' "$OPTIONS_FILE")
PRIVATE_KEY_PATH=$(jq -r '.private_key_path' "$OPTIONS_FILE")
PRIVATE_KEY=$(jq -r '.private_key' "$OPTIONS_FILE")
SSH_EXTRA_OPTIONS=$(jq -r '.ssh_extra_options' "$OPTIONS_FILE")

# Write private key if provided
if [ -n "$PRIVATE_KEY" ] && [ "$PRIVATE_KEY" != "null" ]; then
    log "Writing private key to $PRIVATE_KEY_PATH"
    mkdir -p "$(dirname "$PRIVATE_KEY_PATH")"
    echo "$PRIVATE_KEY" > "$PRIVATE_KEY_PATH"
    chmod 600 "$PRIVATE_KEY_PATH"
fi

if [ ! -f "$PRIVATE_KEY_PATH" ]; then
    log "ERROR: private key not found at $PRIVATE_KEY_PATH"
    exit 1
fi

# Ensure known_hosts entry: attempt to fetch host key (best-effort), but skip failure
ssh-keyscan -p "$REMOTE_SSH_PORT" "$REMOTE_HOST" >> /etc/ssh/ssh_known_hosts 2>/dev/null || true

# Build the reverse tunnel command
SSH_CMD=(ssh -i "$PRIVATE_KEY_PATH" -p "$REMOTE_SSH_PORT" -o "ServerAliveInterval=$SERVER_ALIVE_INTERVAL" -o "ServerAliveCountMax=$SERVER_ALIVE_COUNT_MAX" -o "GatewayPorts=$GATEWAY_PORTS" $SSH_EXTRA_OPTIONS -N -R "${REMOTE_LISTEN_PORT}:${LOCAL_TARGET_HOST}:${LOCAL_TARGET_PORT}" "${REMOTE_USER}@${REMOTE_HOST}")

log "Starting autossh with remote ${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_SSH_PORT} -> ${LOCAL_TARGET_HOST}:${LOCAL_TARGET_PORT} (remote listen ${REMOTE_LISTEN_PORT})"

# If AUTOSSH_MONITOR_PORT is 0, disable monitor port support and use -M 0
if [ "$AUTOSSH_MONITOR_PORT" -eq 0 ]; then
    exec autossh -M 0 "${SSH_CMD[@]}"
else
    exec autossh -M "$AUTOSSH_MONITOR_PORT" "${SSH_CMD[@]}"
fi
