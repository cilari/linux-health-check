# linux-health-check — Project Brief

Handoff from the portfolio session. Full idea list:
`../GitHub_Project_Ideas.md`.

## Goal

A small, original public GitHub repo (github.com/cilari) to show hiring
managers for Cloud Ops / junior SRE roles (e.g. Nuix Associate Cloud
Operations Engineer). No deployment needed.

## What it is

A Bash script that collects the first things to check on a struggling Linux
server and prints one readable report:
- Disk usage (and inodes)
- Memory and swap
- CPU load
- Failed systemd services
- Recent errors in the logs
- Network checks (interfaces, DNS resolution, outbound connectivity, listening ports)

## Shows

Linux, Bash, troubleshooting. Target: about 1 day of work.

## Repo requirements

- Short README: what it does, why I built it, how to run it, sample output.
- GitHub Actions CI: shellcheck + tests (e.g. bats).
- `.gitignore`, LICENSE.
- No secrets in code or history.
- Original work only. Nothing from AWS work: no internal tools, cases or
  customer details; generic Linux knowledge only.
- Check Amazon's internal open-source policy before publishing.

## Working style

- Lari (they/them not stated — use "Lari" or they/them) wants to build it
  themselves with guidance; explain choices, keep scope small.
- Prefer concise answers.
