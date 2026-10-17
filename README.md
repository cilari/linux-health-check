# linux-health-check

[![CI](https://github.com/cilari/linux-health-check/actions/workflows/ci.yml/badge.svg)](https://github.com/cilari/linux-health-check/actions/workflows/ci.yml)

A Bash script that collects the first things to check on a struggling Linux server and prints one readable report.

## What it checks

- **Disk** — usage per mount point with warnings at 80% / 90%, plus inode counts
- **Memory & swap** — current usage via `free -h`
- **CPU** — load average and top processes
- **Failed services** — any systemd units in a failed state
- **Recent errors** — last 20 error-level entries from `journalctl` (falls back to `/var/log/syslog`)
- **Network** — interface addresses, DNS resolution, outbound ping to 1.1.1.1, listening TCP ports

## Why I built it

When a server is acting up, you run the same six checks every time. This script does them in one go and highlights the things that need attention, which is useful both as a first-response tool and as a starting point for learning Linux observability.

## How to run

```bash
git clone https://github.com/cilari/linux-health-check.git
cd linux-health-check
chmod +x health_check.sh
./health_check.sh
```

Tested on Ubuntu 20.04+. Checks that require `systemd` or specific tools degrade gracefully — the script reports "not available" rather than crashing.

## Sample output

```
Linux Health Check
Host: web-01
Date: Sat Oct 17 14:32:01 UTC 2026
User: ubuntu

━━━ DISK USAGE ━━━
Filesystem      Size  Used Avail Use% Mounted on
/dev/root        30G   18G   11G  62% /
tmpfs           1.9G     0  1.9G   0% /dev/shm
  ⚠  Disk at 62% on / (no alert — example only)

  Inodes:
Filesystem      Inodes IUsed   IFree IUse% Mounted on
/dev/root      1966080 85312 1880768    5% /

━━━ MEMORY & SWAP ━━━
              total   used   free  shared  buff/cache  available
Mem:           3.8G   1.2G   1.1G    47M        1.5G       2.4G
Swap:            0B     0B     0B

━━━ CPU LOAD ━━━
 14:32:01 up 4 days,  2:11,  1 user,  load average: 0.12, 0.08, 0.05

━━━ FAILED SERVICES ━━━
  ✔  No failed services

━━━ RECENT ERRORS (last 20) ━━━
(no errors)

━━━ NETWORK ━━━
  Interfaces:
lo     UNKNOWN  127.0.0.1/8
eth0   UP       10.0.1.42/24

  DNS resolution (google.com):
  ✔  Resolved: 142.250.70.142

  Outbound connectivity (1.1.1.1):
  ✔  Outbound ping to 1.1.1.1 succeeded

  Listening ports (TCP):
State  Recv-Q Send-Q Local Address:Port
LISTEN 0      128    0.0.0.0:22

━━━ Done ━━━
```

## CI

GitHub Actions runs [ShellCheck](https://www.shellcheck.net/) (static analysis) and [bats-core](https://github.com/bats-core/bats-core) tests on every push and pull request.
