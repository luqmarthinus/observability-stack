
# Observability Stack

A self-contained observability environment using Docker Compose. Metrics go to Prometheus, logs to Loki (via Grafana Alloy), traces to Tempo, and Grafana ties everything together.


## Badges


[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)
![Docker](https://img.shields.io/badge/docker-%3E%3D26-2496ED?logo=docker&logoColor=white)
![Compose](https://img.shields.io/badge/compose-v2-8c8c8c?logo=docker&logoColor=white)

## Quick start

1. Clone the repository:

```bash
git clone https://github.com/luqmarthinus/observability-stack.git
```
```bash
cd observability-stack
```


2. Run the setup script:

```bash
./scripts/setup.sh
```

This checks dependencies, generates a random Grafana admin password, validates configuration files, and starts all services.

3. Open http://localhost:3000, log in with user `admin` and the password from:

```bash
cat secrets/grafana_admin_password
```


## What's included

| Component  | Purpose | Host port |
|------------|---------|-----------|
| Grafana    | Dashboards and data source hub | 3000 |
| Prometheus | Metrics collection and querying | 9090 |
| Loki       | Log aggregation | 3100 |
| Tempo      | Distributed tracing backend | 3200 |
| Alloy      | Log and metric collection (replaces Promtail) | 12345 |

All containers report health status to Docker Compose and are restarted unless manually stopped.

## Adding data sources in Grafana

After login, go to Configuration > Data Sources and add:

- Prometheus > URL: `http://prometheus:9090`
- Loki > URL: `http://loki:3100`
- Tempo > URL: `http://tempo:3200`

Grafana is on the same Docker network, so the internal service names work.

Grafana doesn't need a separate configuration directory. Its settings are passed through environment variables and a secrets file in `docker-compose.yml`. Persistent state (dashboards, users, data sources) lives in a Docker volume.


## Health checks

All services define Docker health checks. Because the official Tempo and Alloy images are distroless (no shell, no wget/curl), custom Dockerfiles copy a small, statically linked `httpcheck` binary that verifies the relevant HTTP endpoint. Loki uses its native `loki --health` command, while Prometheus and Grafana include `wget`.

## Managing the Grafana password

The password is stored in `secrets/grafana_admin_password`. To reset it:

    1. Stop Grafana: `docker compose stop grafana`
    2. Remove the database volume: `docker volume rm observability-stack_grafana_data`
    3. Regenerate the password[Optional]: `openssl rand -base64 32 | tr -d '\n' > secrets/grafana_admin_password`
    4. Start Grafana: `docker compose up -d grafana`

Grafana will reinitialize with the password from the file.

## Stopping the stack

```bash
docker compose down
```


Add `-v` to also remove data volumes (resets all persisted data):

## Uninstalling the stack completely

To remove all Docker containers, networks, volumes, and the generated password file, run:

```bash
./scripts/uninstall.sh
```


This leaves only the repository code, so you can rebuild later with `./scripts/setup.sh`. The script is safe to run even if the stack is not currently running.

## Troubleshooting

- **Containers not reaching "healthy" status**: Check logs with `docker compose logs <service>`.
- **Grafana login fails**: The password file might contain a trailing newline. Regenerate it as shown above and remove the Grafana volume to force clean initialization.
- **Port conflicts**: Ensure ports 3000, 9090, 3100, 3200, and 12345 are free on your host.
- **Alloy not forwarding logs**: Verify that the Docker socket is mounted (`/var/run/docker.sock:/var/run/docker.sock:ro`) and that `config.alloy` points to `http://loki:3100/loki/api/v1/push`.

## License

MIT. See `LICENSE`.
