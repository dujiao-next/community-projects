#!/usr/bin/env bash
# Dujiao-Next production Docker Compose kit — installer.
# Safe to re-run: it never overwrites an existing .env or config.yml.
set -euo pipefail
cd "$(dirname "$0")"

CONFIG_EXAMPLE_URL="https://raw.githubusercontent.com/dujiao-next/dujiao-next/main/config.yml.example"

fail() { echo "ERROR: $*" >&2; exit 1; }
info() { echo "==> $*"; }

# --- prerequisites -----------------------------------------------------------
command -v docker >/dev/null 2>&1 || fail "docker not found. Install Docker Engine first: https://docs.docker.com/engine/install/"
docker compose version >/dev/null 2>&1 || fail "docker compose plugin (v2) not found. This kit requires 'docker compose', not the legacy 'docker-compose'."
command -v curl >/dev/null 2>&1 || fail "curl not found."
command -v openssl >/dev/null 2>&1 || fail "openssl not found (used to generate secrets)."
command -v python3 >/dev/null 2>&1 || fail "python3 not found (used once to customize config.yml). Alternatively create config.yml by hand from config.yml.example and re-run."

# --- .env --------------------------------------------------------------------
if [ ! -f .env ]; then
  cp .env.example .env
  info "Created .env from .env.example — edit it later to change port/domain."
fi
# shellcheck disable=SC1091
set -a; . ./.env; set +a
APP_PORT="${APP_PORT:-8080}"
BIND_ADDR="${BIND_ADDR:-127.0.0.1}"

# --- config.yml --------------------------------------------------------------
if [ ! -f config.yml ]; then
  info "Downloading official config.yml.example ..."
  curl -fsSL "$CONFIG_EXAMPLE_URL" -o config.yml.tmp
  mv config.yml.tmp config.yml

  info "Generating strong secrets and Docker settings in config.yml ..."
  S1="$(openssl rand -hex 32)" S2="$(openssl rand -hex 32)" S3="$(openssl rand -hex 32)" \
  ADMIN_PATH="/panel-$(openssl rand -hex 4)" \
  python3 - <<'PYEOF'
import os, re, sys

path = "config.yml"
with open(path, encoding="utf-8") as f:
    lines = f.read().splitlines()

secrets = {
    ("app", "secret_key"): os.environ["S1"],
    ("jwt", "secret"): os.environ["S2"],
    ("user_jwt", "secret"): os.environ["S3"],
    ("web", "admin_path"): os.environ["ADMIN_PATH"],
}
section = None
out = []
i = 0
while i < len(lines):
    line = lines[i]
    m = re.match(r"^([a-z_]+):\s*$", line)
    if m:
        section = m.group(1)
    km = re.match(r"^(\s*)([a-z_]+):(\s*)(\S+)?(.*)$", line)
    if km and section:
        indent, key, sp, val, rest = km.groups()
        if (section, key) in secrets and len(indent) == 2:
            val = secrets[(section, key)]
            if key == "admin_path":
                val = f'"{val}"'
            line = f"{indent}{key}: {val}"
        elif section == "server" and key == "mode" and len(indent) == 2:
            line = f"{indent}{key}: release{rest}"
        elif section in ("redis", "queue") and key == "host" and len(indent) == 2:
            line = f"{indent}{key}: redis{rest}"
        elif section == "server" and key == "trusted_proxies" and len(indent) == 2:
            out.append(line)
            i += 1
            # copy existing list items, then add the Docker bridge range
            while i < len(lines) and re.match(r"^\s*-\s", lines[i]):
                out.append(lines[i])
                i += 1
            out.append("    - 172.16.0.0/12  # Docker bridge networks (added by docker-compose-production-kit)")
            continue
    out.append(line)
    i += 1

with open(path, "w", encoding="utf-8") as f:
    f.write("\n".join(out) + "\n")
print("config.yml customized: 3 secrets generated, web.admin_path randomized, server.mode=release, redis/queue host=redis, trusted_proxies += 172.16.0.0/12")
PYEOF
  chmod 600 config.yml
  info "config.yml created (permissions 600). Keep it private — it holds your secrets."
else
  info "config.yml already exists — leaving it untouched."
fi

# --- data dirs ---------------------------------------------------------------
mkdir -p data/db data/uploads data/logs data/redis backups

# --- start -------------------------------------------------------------------
info "Pulling images ..."
docker compose pull
info "Starting Dujiao-Next ..."
docker compose up -d

# --- health check ------------------------------------------------------------
HEALTH_URL="http://127.0.0.1:${APP_PORT}/health"
info "Waiting for ${HEALTH_URL} (up to 120s) ..."
ok=0
for _ in $(seq 1 60); do
  if curl -fsS -m 3 "$HEALTH_URL" >/dev/null 2>&1; then ok=1; break; fi
  sleep 2
done
if [ "$ok" != "1" ]; then
  echo "The app did not become healthy in time. Recent app logs:" >&2
  docker compose logs --tail=50 app >&2 || true
  fail "health check failed — see logs above (full logs: docker compose logs -f app)"
fi

ADMIN_PATH="$(grep -E '^\s*admin_path:' config.yml | head -1 | sed -E 's/.*admin_path:\s*"?([^"# ]*)".*/\1/')"
ADMIN_PATH="${ADMIN_PATH:-/admin}"
echo
echo "============================================================"
echo " Dujiao-Next is up and healthy."
echo " Storefront : http://${BIND_ADDR}:${APP_PORT}/"
echo " Admin panel: http://${BIND_ADDR}:${APP_PORT}${ADMIN_PATH}"
echo
echo " First run? If you did not preset bootstrap.default_admin_*"
echo " in config.yml, the app created user 'admin' with a one-time"
echo " random password printed ONCE in the first-start logs:"
echo "   docker compose logs app | grep -A1 -B1 '默认超级管理员'"
echo " Log in and change it immediately. Details:"
echo " https://dujiao-next.com/deploy/"
echo
echo " Public HTTPS: set SITE_DOMAIN in .env, then run:"
echo "   docker compose --profile proxy up -d"
echo "============================================================"
