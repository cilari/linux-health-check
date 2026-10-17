#!/usr/bin/env bats

SCRIPT="${BATS_TEST_DIRNAME}/../health_check.sh"

setup() {
  # Stub commands that require a real Linux/systemd environment
  export STUB_BIN="${BATS_TEST_TMPDIR}/bin"
  mkdir -p "${STUB_BIN}"

  # systemctl: exit 0, no output (no failed units)
  printf '#!/usr/bin/env bash\nexit 0\n' > "${STUB_BIN}/systemctl"
  chmod +x "${STUB_BIN}/systemctl"

  # journalctl: exit 0, no output
  printf '#!/usr/bin/env bash\nexit 0\n' > "${STUB_BIN}/journalctl"
  chmod +x "${STUB_BIN}/journalctl"

  export PATH="${STUB_BIN}:${PATH}"
}

@test "script exits with status 0" {
  run bash "${SCRIPT}"
  [ "${status}" -eq 0 ]
}

@test "output contains DISK USAGE section" {
  run bash "${SCRIPT}"
  [[ "${output}" == *"DISK USAGE"* ]]
}

@test "output contains MEMORY section" {
  run bash "${SCRIPT}"
  [[ "${output}" == *"MEMORY"* ]]
}

@test "output contains CPU LOAD section" {
  run bash "${SCRIPT}"
  [[ "${output}" == *"CPU LOAD"* ]]
}

@test "output contains FAILED SERVICES section" {
  run bash "${SCRIPT}"
  [[ "${output}" == *"FAILED SERVICES"* ]]
}

@test "output contains RECENT ERRORS section" {
  run bash "${SCRIPT}"
  [[ "${output}" == *"RECENT ERRORS"* ]]
}

@test "output contains NETWORK section" {
  run bash "${SCRIPT}"
  [[ "${output}" == *"NETWORK"* ]]
}

@test "output contains hostname" {
  run bash "${SCRIPT}"
  [[ "${output}" == *"Host:"* ]]
}

@test "no failed units reports OK" {
  run bash "${SCRIPT}"
  # systemctl stub exits 0 with no output, so the script should report clean
  [[ "${output}" == *"No failed services"* ]]
}
