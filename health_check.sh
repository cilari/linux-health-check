#!/usr/bin/env bash
# Quick health snapshot of a Linux server.
# Checks: disk, memory, CPU, failed services, recent errors, network.

set -euo pipefail

# Disable colors when stdout is not a terminal (piped, redirected, etc.)
if [[ -t 1 ]]; then
  RED='\033[0;31m'
  YELLOW='\033[1;33m'
  GREEN='\033[0;32m'
  CYAN='\033[0;36m'
  BOLD='\033[1m'
  NC='\033[0m'
else
  RED='' YELLOW='' GREEN='' CYAN='' BOLD='' NC=''
fi

header() { printf "\n%s━━━ %s ━━━%s\n" "${CYAN}${BOLD}" "$1" "${NC}"; }
ok()     { printf "%s  ✔  %s%s\n"      "${GREEN}"           "$1" "${NC}"; }
warn()   { printf "%s  ⚠  %s%s\n"      "${YELLOW}"          "$1" "${NC}"; }
alert()  { printf "%s  ✖  %s%s\n"      "${RED}"             "$1" "${NC}"; }

check_disk() {
  header "DISK USAGE"
  df -h 2>/dev/null

  # Flag partitions approaching or exceeding safe limits
  while IFS= read -r line; do
    pct=$(echo "$line" | awk '{gsub(/%/, ""); print $5}')
    mnt=$(echo "$line" | awk '{print $NF}')
    if [[ "$pct" =~ ^[0-9]+$ ]]; then
      if (( pct >= 90 )); then
        alert "Disk at ${pct}% on ${mnt} — critically full"
      elif (( pct >= 80 )); then
        warn  "Disk at ${pct}% on ${mnt}"
      fi
    fi
  done < <(df -h | tail -n +2)

  printf "\n  Inodes:\n"
  df -i 2>/dev/null
}

check_memory() {
  header "MEMORY & SWAP"
  if command -v free &>/dev/null; then
    free -h
  else
    printf "  (free not available)\n"
  fi
}

check_cpu() {
  header "CPU LOAD"
  uptime
  printf "\n  Top processes:\n"
  if command -v top &>/dev/null; then
    # GNU top: -b batch mode, -n 1 single iteration
    # macOS top: -l 1 single iteration
    top -b -n 1 2>/dev/null | head -20 \
      || top -l 1 2>/dev/null | head -20 \
      || true
  fi
}

check_services() {
  header "FAILED SERVICES"
  if command -v systemctl &>/dev/null; then
    failed=$(systemctl --failed --no-legend --no-pager 2>/dev/null || true)
    if [[ -z "$failed" ]]; then
      ok "No failed services"
    else
      alert "Failed services detected:"
      printf "%s\n" "$failed"
    fi
  else
    printf "  (systemd not available)\n"
  fi
}

check_logs() {
  header "RECENT ERRORS (last 20)"
  if command -v journalctl &>/dev/null; then
    journalctl -p err -n 20 --no-pager 2>/dev/null \
      || printf "  (journalctl returned an error)\n"
  elif [[ -r /var/log/syslog ]]; then
    grep -iE "error|crit|emerg" /var/log/syslog | tail -20
  elif [[ -r /var/log/messages ]]; then
    grep -iE "error|crit|emerg" /var/log/messages | tail -20
  else
    printf "  (no readable log source found)\n"
  fi
}

check_network() {
  header "NETWORK"

  printf "\n  Interfaces:\n"
  if command -v ip &>/dev/null; then
    ip -brief addr 2>/dev/null || true
  elif command -v ifconfig &>/dev/null; then
    ifconfig 2>/dev/null | grep -E "^[a-zA-Z]|inet " || true
  else
    printf "  (ip/ifconfig not available)\n"
  fi

  printf "\n  DNS resolution (google.com):\n"
  if command -v dig &>/dev/null; then
    result=$(dig +short google.com 2>/dev/null | head -3 || true)
    if [[ -n "$result" ]]; then
      ok "Resolved: ${result}"
    else
      warn "dig returned no result for google.com"
    fi
  elif command -v nslookup &>/dev/null; then
    result=$(nslookup google.com 2>/dev/null \
      | awk '/^Address/ && !/53$/ {print $2; exit}' || true)
    if [[ -n "$result" ]]; then
      ok "Resolved: ${result}"
    else
      warn "nslookup returned no result for google.com"
    fi
  else
    printf "  (dig/nslookup not available)\n"
  fi

  printf "\n  Outbound connectivity (1.1.1.1):\n"
  if ping -c 1 -W 3 1.1.1.1 &>/dev/null 2>&1; then
    ok "Outbound ping to 1.1.1.1 succeeded"
  else
    warn "Outbound ping to 1.1.1.1 failed (may be ICMP-blocked by firewall)"
  fi

  printf "\n  Listening ports (TCP):\n"
  if command -v ss &>/dev/null; then
    ss -tlnp 2>/dev/null || true
  elif command -v netstat &>/dev/null; then
    netstat -tlnp 2>/dev/null || true
  else
    printf "  (ss/netstat not available)\n"
  fi
}

main() {
  printf "%sLinux Health Check%s\n" "${BOLD}" "${NC}"
  printf "Host: %s\n" "$(hostname)"
  printf "Date: %s\n" "$(date)"
  printf "User: %s\n" "$(whoami)"

  check_disk
  check_memory
  check_cpu
  check_services
  check_logs
  check_network

  printf "\n%s━━━ Done ━━━%s\n\n" "${GREEN}${BOLD}" "${NC}"
}

main "$@"
