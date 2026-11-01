# Dujiao-Next Docker Compose Production Kit

A production-ready Docker Compose deployment for [Dujiao-Next](https://github.com/dujiao-next/dujiao-next), the open-source digital goods e-commerce system.

The official docs cover Docker with a single `docker run` line. This kit turns that into an operable deployment: generated secrets, a real `config.yml`, Redis wired in, health checks, optional automatic HTTPS, and backup/restore scripts — all in one folder you can copy to any server.

## Features

- **One-command install** — `install.sh` checks prerequisites, downloads the official `config.yml.example`, generates the three required secrets, and starts the stack.
- **Secure defaults** — three distinct random secrets (`app.secret_key`, `jwt.secret`, `user_jwt.secret`), a **randomized admin path** (the app itself warns that the default `/admin` invites automated scanning), `server.mode: release`, app port bound to localhost unless you say otherwise, `config.yml` created with `600` permissions and never overwritten on re-runs.
- **Redis included** — the default `config.yml` expects Redis for cache and the asynq queue; the kit runs Redis 7 with AOF persistence and points both `redis` and `queue` sections at it.
- **Reverse-proxy ready** — `server.trusted_proxies` is extended with the Docker bridge range (`172.16.0.0/12`) so real client IPs survive your proxy.
- **Automatic HTTPS (optional)** — enable the `proxy` profile and Caddy serves your domain with Let's Encrypt certificates.
- **Backup & restore** — `backup.sh` snapshots the SQLite database, uploads and config (briefly stopping the app for a consistent copy); `restore.sh` rolls back with a confirmation prompt and a health check.

## Prerequisites

- Linux server (tested on Ubuntu 24.04) with **Docker Engine + Compose v2 plugin** — [install guide](https://docs.docker.com/engine/install/)
- `curl`, `openssl`, `python3` (used once by `install.sh` to customize `config.yml`; skip it by writing `config.yml` yourself)
- For HTTPS: a domain whose DNS records point at the server, ports 80/443 open

## Installation

```bash
git clone https://github.com/dujiao-next/community-projects.git
cd community-projects/scripts/docker-compose-production-kit

./install.sh
```

The installer prints your storefront and admin URLs once `GET /health` returns OK. On a fresh database, either fill in `bootstrap.default_admin_username` / `default_admin_password` in `config.yml` **before** the first start, or let the app create user `admin` automatically — it prints a **one-time random password** in the first-start logs (look for the “已创建默认超级管理员” line in `docker compose logs app`). Log in and change it immediately.

To enable public HTTPS afterwards:

```bash
# set SITE_DOMAIN=shop.example.com in .env first
docker compose --profile proxy up -d
```

## Configuration

### `.env`

| Variable      | Default                 | Meaning                                             |
| ------------- | ----------------------- | --------------------------------------------------- |
| `IMAGE`       | `dujiaonext/dujiao-next` | App image                                           |
| `TAG`         | `latest`                | Image tag (pin a release tag for reproducible deploys) |
| `BIND_ADDR`   | `127.0.0.1`             | Host interface for the app port. `0.0.0.0` exposes it directly |
| `APP_PORT`    | `8080`                  | Host port mapped to the app                         |
| `SITE_DOMAIN` | *(empty)*               | Domain for the Caddy `proxy` profile                |

### `config.yml`

Generated from the official `config.yml.example` with these changes: three secrets randomized, `web.admin_path` randomized (find yours in `config.yml` or in the installer output), `server.mode` set to `release`, `redis.host` / `queue.host` set to `redis`, Docker bridge range added to `server.trusted_proxies`. Everything else stays at upstream defaults — see the comments in the file and the [official configuration docs](https://dujiao-next.com/) before changing database, email or payment-related settings.

### Data layout

```
data/db/        SQLite database (database.dsn ./db/dujiao.db)
data/uploads/   user uploads
data/logs/      app logs
data/redis/     Redis AOF data
backups/        archives created by backup.sh
```

## Usage

```bash
docker compose ps                 # status
docker compose logs -f app        # app logs
docker compose restart app        # restart app only
docker compose down               # stop everything (data is kept)

./backup.sh                       # consistent backup (stops app briefly)
./backup.sh --live                # backup without stopping
./restore.sh backups/dujiao-backup-YYYYMMDD-HHMMSS.tar.gz
```

### Upgrading

```bash
# optionally pin TAG in .env to the target release first
docker compose pull
docker compose up -d
./backup.sh                       # keep a fresh snapshot
```

### Lite mode (no Redis)

The default run mode (`all` = HTTP server + background worker) **requires** the queue, so it needs Redis — that is why this kit ships Redis by default. To go lite anyway: set `enabled: false` in both the `redis:` and `queue:` sections of `config.yml`, remove the `redis` service plus the app's `depends_on` from `docker-compose.yml`, and start the app in API-only mode by adding `command: ["./dujiao-next", "-mode", "api"]` to the `app` service. Be aware that background jobs (order emails, upstream inventory sync, …) do not run in this mode. (Verified against v1.5.1: with the queue disabled, the default mode exits with `服务运行失败: queue disabled`, while `-mode api` serves normally.)

## FAQ

**The health check fails right after install.**
Give the first start a moment (database migrations run on boot), then inspect `docker compose logs --tail=100 app`. The most common causes are a hand-edited `config.yml` with placeholder secrets still in place — the app refuses to start until all three secrets are replaced — or port `8080` already in use (change `APP_PORT` in `.env`).

**I already have Nginx on the host. Do I need Caddy?**
No. Keep `BIND_ADDR=127.0.0.1`, skip the `proxy` profile, and proxy `127.0.0.1:${APP_PORT}` from your Nginx. The kit already trusts Docker bridge proxies in `config.yml`.

**Can I use PostgreSQL instead of SQLite?**
Yes — set `database.driver: postgres` and a suitable `dsn` in `config.yml`, and add a Postgres service to the compose file. This kit ships the SQLite default because it matches the upstream default and keeps backups trivial.

**Is `config.yml` safe to commit to my own git repo?**
No. It contains your three secrets. It is listed in this kit's `.gitignore`; keep it that way.

## Compatibility

- Dujiao-Next: verified end-to-end against the official `dujiaonext/dujiao-next:latest` image at **v1.5.1** (2026-11-01) — the generated `config.yml` boots the real binary, migrations run, `GET /health` returns `{"status":"ok"}`, and the storefront and admin panel respond. The config generator targets the main-branch `config.yml.example` layout; if upstream renames the secret keys, regenerate `config.yml` by hand.
- Requires Docker Compose v2 (`docker compose`). Docker Desktop works too.

## Maintainer

Maintained by **Solvent Agent** — an AI-agent-run project. Questions and issues: please open an issue in the [community-projects repository](https://github.com/dujiao-next/community-projects/issues) and mention `docker-compose-production-kit`.

## License

[MIT](LICENSE)
