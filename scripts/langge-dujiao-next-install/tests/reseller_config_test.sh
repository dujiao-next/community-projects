#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALLER="${SCRIPT_DIR}/../dujiao-next-install.sh"
LOADER="$(mktemp)"
trap 'rm -f "${LOADER}"' EXIT

# Load functions without entering the interactive main menu.
sed '$d' "${INSTALLER}" > "${LOADER}"
# shellcheck source=/dev/null
source "${LOADER}"

fail() {
  printf 'FAIL: %s\n' "$1" >&2
  exit 1
}

assert_contains() {
  local file="$1" expected="$2"
  grep -Fq -- "${expected}" "${file}" || fail "expected ${file} to contain: ${expected}"
}

assert_equals() {
  local expected="$1" actual="$2" message="$3"
  [[ "${expected}" == "${actual}" ]] || fail "${message}: expected ${expected}, got ${actual}"
}

test_render_reseller_config_block() {
  local expected actual
  expected="$(cat <<'EOF'
reseller:
  enabled: true
  main_hosts:
    - shop.example.com
    - admin.example.com
    - api.example.com
    - localhost
    - 127.0.0.1
    - ::1
  trusted_forwarded_host: false
  subdomain_base: "shop.example.com"
  self_apply_enabled: true
  settlement_confirm_days: 7
EOF
)"
  actual="$(render_reseller_config_block "shop.example.com" "admin.example.com" "api.example.com")"
  assert_equals "${expected}" "${actual}" "rendered reseller config"
}

test_ensure_reseller_config_appends_when_missing() {
  local tmp config count
  tmp="$(mktemp -d)"
  config="${tmp}/config.yml"
  cat > "${config}" <<'EOF'
server:
  host: 0.0.0.0
  port: 8080
EOF

  ensure_reseller_config_present "${config}" "shop.example.com" "admin.example.com" "api.example.com"

  assert_contains "${config}" "server:"
  assert_contains "${config}" "reseller:"
  assert_contains "${config}" "    - shop.example.com"
  assert_contains "${config}" "    - admin.example.com"
  assert_contains "${config}" "    - api.example.com"
  count="$(grep -Ec '^reseller[[:space:]]*:' "${config}")"
  assert_equals "1" "${count}" "reseller block count after append"
  [[ -f "${config}.bak" ]] || fail "expected backup file ${config}.bak"
  rm -rf "${tmp}"
}

test_new_install_config_writers_include_reseller_block() {
  local tmp docker_config binary_config
  tmp="$(mktemp -d)"
  docker_config="${tmp}/docker-config.yml"
  binary_config="${tmp}/binary-config.yml"

  write_docker_config_file "${docker_config}" "sqlite" "redis-pass" "" "" "" \
    "shop.example.com" "admin.example.com" "api.example.com"
  write_binary_config_file "${binary_config}" "${tmp}" "8080" "admin" "Admin@123456" "redis-pass" \
    "sqlite" "" "" "" "" "" "shop.example.com" "admin.example.com" "api.example.com"

  assert_contains "${docker_config}" "reseller:"
  assert_contains "${docker_config}" "    - shop.example.com"
  assert_contains "${docker_config}" "    - admin.example.com"
  assert_contains "${docker_config}" "    - api.example.com"
  assert_contains "${docker_config}" '  subdomain_base: "shop.example.com"'
  assert_contains "${binary_config}" "reseller:"
  assert_contains "${binary_config}" "    - shop.example.com"
  assert_contains "${binary_config}" "    - admin.example.com"
  assert_contains "${binary_config}" "    - api.example.com"
  assert_contains "${binary_config}" '  subdomain_base: "shop.example.com"'
  rm -rf "${tmp}"
}

test_ensure_reseller_config_skips_existing_block() {
  local tmp config before after count
  tmp="$(mktemp -d)"
  config="${tmp}/config.yml"
  cat > "${config}" <<'EOF'
server:
  host: 0.0.0.0

reseller:
  enabled: false
EOF
  before="$(cat "${config}")"

  ensure_reseller_config_present "${config}" "shop.example.com" "admin.example.com" "api.example.com"
  after="$(cat "${config}")"

  assert_equals "${before}" "${after}" "existing reseller config should not be changed"
  count="$(grep -Ec '^reseller[[:space:]]*:' "${config}")"
  assert_equals "1" "${count}" "reseller block count after skip"
  [[ ! -f "${config}.bak" ]] || fail "did not expect backup when skipping existing reseller config"
  rm -rf "${tmp}"
}

test_render_reseller_config_block
test_ensure_reseller_config_appends_when_missing
test_new_install_config_writers_include_reseller_block
test_ensure_reseller_config_skips_existing_block

printf 'reseller config tests passed\n'
