# OpenSimulator / OS Grid Docker Stack with AI Experiments

[![Docker Hub Standalone](https://img.shields.io/badge/Docker%20Hub-bithatch%2Fopensim--ai--standalone-2496ED?logo=docker&logoColor=white)](https://hub.docker.com/repository/docker/bithatch/opensim-ai-standalone/general)
[![Docker Hub OSGrid](https://img.shields.io/badge/Docker%20Hub-bithatch%2Fopensim--ai--osgrid-2496ED?logo=docker&logoColor=white)](https://hub.docker.com/repository/docker/bithatch/opensim-ai-osgrid/general)

A Docker stack for OpenSimulator and OS Grid that makes it easy to setup an AI enabled virtual world.

This is done by integrating [opensim-console2mcp](https://github.com/opensim-stack/opensim-console2mcp), [opensim-metaverese2mcp](https://github.com/opensim-stack/opensim-metaverse2mcp), and [opensim-opencode](https://github.com/opensim-stack/opensim-opencode) as part of the stack. `opensim-console2mcp` bridges the OpenSimulator REST console to MCP, `opensim-metaverse2mcp` provides a bridge to a bot controlled by MCP, and `opensim-opencode` runs Opencode in server mode preconfigured to use those MCP bridges.

 * Manage your OpenSimulator server using natural language. Anything that the console can do, your AI can do including region management, user management, configuration and lots more.
 * The AI bot can walk, run or fly to any point in the region, or teleport to others.
 * The AI bot can create, position, scale, rotate and texture prims.
 * The AI bot can create and configure your environment settings.

## Work In Progress!!!!

*Note, the current builds do not yet a human interface where you can issue instructions. 
You can however run an opencode instance (or any other framework that supports MCP) on a completely separate machine, and attach that to the two MCP servers. Full instructions on how to do this will be published very soon, and there will be a in world chat interface*   

## Build Types

1. Source mode: default to published source image; optionally build from git via local override.
2. Release mode: default to published release image; optionally build from official binary archive.
3. OSGrid mode: default to published OSGrid image; optionally build from OSGrid package and generate `Regions.ini`.

*Note: security defaults are intentionally lax and mainly suitable for local use. All components support proper authentication, so you should replace default credentials before exposing services externally.*

## Files

- Dockerfile
- docker-compose.yml (source mode default)
- docker-compose.release.yml (official binary release override)
- docker-compose.osgrid.yml (OSGrid override)
- docker-compose.local.yml (local source build override)
- docker-compose.release.local.yml (local release build override)
- docker-compose.osgrid.local.yml (local OSGrid build override)
- .env.example
- docker/init-standalone.sh
- docker/init-osgrid.sh
- docker/entrypoint.sh

## Prerequisites

- Docker Engine
- Docker Compose v2 (`docker compose`)

## Quick Start

### 0) Initialize environment file

```bash
cp .env.example .env
```

### Optional launcher scripts

The project includes helper scripts that run the correct compose command for each mode:

- ./run.sh
- ./run-release.sh
- ./run-osgrid.sh

Each script will auto-create `.env` from `.env.example` if it does not exist.

By default, compose files use published images via these variables:

- `OPENSIM_SOURCE_IMAGE` (default `bithatch/opensim-ai-standalone:dev-latest`)
- `OPENSIM_RELEASE_IMAGE` (default `bithatch/opensim-ai-standalone:latest`)
- `OPENSIM_OSGRID_IMAGE` (default `bithatch/opensim-ai-osgrid:latest`)
- `OPENSIM_METAVERSE2MCP_IMAGE` (default `bithatch/opensim-metaverse2mcp:latest`)

The helper scripts use local override compose files (`docker-compose.*.local.yml`) to
build and run local images with the current local tags.

Use cases:

- Use plain `docker compose ... up -d` to run published images.
- Use `./run.sh`, `./run-release.sh`, or `./run-osgrid.sh` for local builds.

## Mode 1: Source mode

This is the default compose stack (`docker-compose.yml`).
By default it pulls the published source image. Local source builds are done
through `./run.sh` using `docker-compose.local.yml`.

When building locally, it clones from:

- git://opensimulator.org/git/opensim

You can override clone URL/ref via `.env`:

- OPENSIM_GIT_URL
- OPENSIM_GIT_REF

Run:

```bash
docker compose up -d
```

Or use:

```bash
./run.sh
```

This mode runs standalone OpenSimulator with MariaDB.

## Mode 2: Release mode

This mode runs its own standalone + MariaDB stack.
By default it pulls the published release image. Local release builds are done
through `./run-release.sh` using `docker-compose.release.local.yml`.

When building locally, OpenSim binaries come from an official download archive.

Default URL in `.env.example`:

- http://opensimulator.org/dist/opensim-0.9.3.0.tar.gz

You may switch to zip/tar.gz by setting `OPENSIM_RELEASE_URL`.

Run:

```bash
docker compose -f docker-compose.release.yml up -d
```

Or use:

```bash
./run-release.sh
```

## Mode 3: OSGrid-ready Hypergrid mode

By default this mode pulls the published OSGrid image. Local OSGrid builds are
done through `./run-osgrid.sh` using `docker-compose.osgrid.local.yml`.

When building locally, this mode downloads the OSGrid distribution:

- https://download.osgrid.org/osgrid-opensim-04172026.v0.9.3.ef8a36b.zip

It includes its own MariaDB service in this compose stack.
It creates `Regions/Region.ini` with the minimum required details for joining Hypergrid.

Required variables in `.env` for this mode:

- OSGRID_REGION_NAME
- OSGRID_REGION_UUID
- OSGRID_REGION_LOCATION
- OSGRID_EXTERNAL_HOSTNAME

Optional:

- OSGRID_INTERNAL_PORT (default 9000)

Run:

```bash
docker compose -f docker-compose.osgrid.yml up -d
```

Or use:

```bash
./run-osgrid.sh
```

### Required OSGrid Region Fields

The generated `Regions/Region.ini` contains:

- Region Name (`OSGRID_REGION_NAME`)
- RegionUUID (`OSGRID_REGION_UUID`)
- Location (`OSGRID_REGION_LOCATION`)
- ExternalHostName (`OSGRID_EXTERNAL_HOSTNAME`)


## Standalone (MariaDB) Variables

These apply to modes 1 and 2:

- OPENSIM_HOSTNAME
- OPENSIM_REGION_NAME
- OPENSIM_REGION_X
- OPENSIM_REGION_Y
- OPENSIM_REGION_PORT
- OPENSIM_ESTATE_NAME
- OPENSIM_ESTATE_OWNER_FIRST
- OPENSIM_ESTATE_OWNER_LAST
- OPENSIM_ESTATE_OWNER_PASSWORD
- OPENSIM_ESTATE_OWNER_EMAIL
- OPENSIM_ESTATE_OWNER_UUID
- OPENSIM_GRID_NAME
- OPENSIM_GRID_NICK
- OPENSIM_WELCOME_MESSAGE
- OPENSIM_CONSOLE_MODE
- OPENSIM_CONSOLE_USER
- OPENSIM_CONSOLE_PASS
- OPENSIM_CREATE_BOT_USER
- OPENSIM_LOGIN_FIRSTNAME
- OPENSIM_LOGIN_LASTNAME
- OPENSIM_LOGIN_PASSWORD
- OPENSIM_LOGIN_EMAIL
- OPENSIM_LOGIN_UUID
- OPENSIM_LOGIN_MODEL
- MARIADB_HOST
- MARIADB_DATABASE
- MARIADB_USER
- MARIADB_PASSWORD
- MARIADB_ROOT_PASSWORD

Legacy compatibility: `MYSQL_*` names are still accepted as fallbacks, but new
setups should use `MARIADB_*`.

## REST Console

This project enables the OpenSimulator REST console by default via:

- `OPENSIM_CONSOLE_MODE=rest`
- `OPENSIM_CONSOLE_USER`
- `OPENSIM_CONSOLE_PASS`

The REST endpoints are available on the simulator HTTP port:

- `POST /StartSession/`
- `POST /ReadResponses/<SessionID>/`
- `POST /SessionCommand/`
- `POST /CloseSession/`

For default standalone settings, this is usually:

- `http://<host>:${OPENSIM_REGION_PORT}`

If you already initialized a config volume before enabling these settings,
recreate the stack with volumes to regenerate config files:

```bash
docker compose down -v
docker compose up -d
```

## OpenSim Metaverse MCP Server (opensim-metaverse2mcp)

This project also runs a bot-side MCP service using
`bithatch/opensim-metaverse2mcp:latest`.

The service logs in a bot avatar and exposes in-world tools (movement, prim and
environment actions) over MCP HTTP.

The metaverse MCP sidecar uses these environment variables:

- `OPENSIM_METAVERSE2MCP_IMAGE`
- `METAVERSE_MCP_TRANSPORT` (`http` or `sse`)
- `METAVERSE_MCP_HOST`
- `METAVERSE_MCP_PORT`
- `METAVERSE_MCP_HTTP_ENDPOINT`
- `METAVERSE_MCP_HTTP_BEARER_TOKEN`
- `METAVERSE_MCP_HTTP_DISALLOW_DELETE`
- `METAVERSE_MCP_DIAGNOSTICS`
- `OPENSIM_LOGIN_FIRSTNAME`
- `OPENSIM_LOGIN_LASTNAME`
- `OPENSIM_LOGIN_PASSWORD`
- `OPENSIM_LOGIN_URI`
- `OPENSIM_LOGIN_START`
- `BOT_LOGIN_TIMEOUT_SECONDS`

Default endpoint inside the stack:

- `http://opensim-metaverse2mcp:8999/mcp`

Bot bootstrap behavior:

- `OPENSIM_CREATE_BOT_USER=true` adds a startup console command that creates the
  bot user using `OPENSIM_LOGIN_FIRSTNAME`, `OPENSIM_LOGIN_LASTNAME`,
  `OPENSIM_LOGIN_PASSWORD`, `OPENSIM_LOGIN_EMAIL`, `OPENSIM_LOGIN_UUID`, and
  `OPENSIM_LOGIN_MODEL`.
- If `OPENSIM_LOGIN_UUID` is blank, init generates a UUID automatically.
- Set `OPENSIM_LOGIN_MODEL` to `""` if you want an empty model/avatar template.

## OpenSim MCP Server (opensim-console2mcp)

This project uses the published Docker image
`bithatch/opensim-console2mcp:latest`.

The MCP server uses these environment variables:

- `MCP_TRANSPORT` (`http`, `sse`, or `stdio`)
- `MCP_HOST`
- `MCP_PORT`
- `OPENSIM_CONSOLE_URL`
- `OPENSIM_CONSOLE_USER`
- `OPENSIM_CONSOLE_PASS`

These should match the REST console credentials already configured in this
project (`OPENSIM_CONSOLE_USER` / `OPENSIM_CONSOLE_PASS`).

Notes:

- `http://opensim:9000` uses the internal Docker network service name.
- If your simulator HTTP listener is not 9000 internally, adjust `OPENSIM_CONSOLE_URL`.
- This image defaults to HTTP transport for remote MCP access in stack deployments.
- To run classic subprocess mode instead, set `MCP_TRANSPORT=stdio` and remove port mapping.

## Opencode Server (opensim-opencode)

This stack includes an Opencode server service using
`bithatch/opensim-opencode:latest`.

Defaults:

- Server port: `8998` (`OPENCODE_PORT`, fallback `OPENCODE_WEB_PORT` for compatibility)
- MCP endpoint URL for Opencode: `http://opensim-console2mcp:9001/mcp` (`OPENCODE_MCP_URL`)
- Metaverse MCP endpoint URL for Opencode: `http://opensim-metaverse2mcp:8999/mcp` (`OPENCODE_METAVERSE_MCP_URL`)
- MCP auth: none by default
- Host bind: `0.0.0.0` (`OPENCODE_HOST`)
- Server password pass-through: `OPENCODE_SERVER_PASSWORD`
- Project directory: `/workspace` (`OPENCODE_PROJECT_DIR`)

At startup, an init container writes `opencode.json` into the shared config
volume so Opencode is preconfigured to use the MCP sidecar.

Generated config content:

```json
{
  "$schema": "https://opencode.ai/config.json",
  "mcp": {
    "local_host_mcp": {
      "type": "remote",
      "url": "http://opensim-console2mcp:9001/mcp",
      "enabled": true
    },
    "metaverse_mcp": {
      "type": "remote",
      "url": "http://opensim-metaverse2mcp:8999/mcp",
      "enabled": true
    }
  }
}
```

Volume mappings used by the service:

- Source/release stacks:
  - `opensim-config` -> `/workspace`
- OSGrid stack:
  - `osgrid-config` -> `/workspace`
- All stacks:
  - `opencode-data` -> `/root/.local/share/opencode`
  - `opencode-state` -> `/root/.local/state/opencode`
  - `opencode-cache` -> `/root/.cache/opencode`
  - `opencode-config` -> `/root/.config/opencode`

## Publish Images To Docker Hub (bithatch)

These commands publish all runtime variants to the Docker Hub namespace
`bithatch`.

### 1) Login

```bash
docker login
```

### 2) Set optional tag suffix

```bash
export TAG_DATE=$(date +%Y%m%d)
```

### 3) Build and push source-runtime image

```bash
docker build \
  --target source-runtime \
  --build-arg OPENSIM_GIT_URL=git://opensimulator.org/git/opensim \
  --build-arg OPENSIM_GIT_REF=master \
  -t bithatch/opensim-ai-standalone:dev-latest \
  -t bithatch/opensim-ai-standalone:dev-${TAG_DATE} \
  .

docker push bithatch/opensim-ai-standalone:dev-latest
docker push bithatch/opensim-ai-standalone:dev-${TAG_DATE}
```

### 4) Build and push official-release runtime image

```bash
docker build \
  --target release-runtime \
  --build-arg OPENSIM_RELEASE_URL=http://opensimulator.org/dist/opensim-0.9.3.0.tar.gz \
  -t bithatch/opensim-ai-standalone:latest \
  -t bithatch/opensim-ai-standalone:${TAG_DATE} \
  .

docker push bithatch/opensim-ai-standalone:latest
docker push bithatch/opensim-ai-standalone:${TAG_DATE}
```

### 5) Build and push OSGrid runtime image

```bash
docker build \
  --target osgrid-runtime \
  --build-arg OSGRID_RELEASE_URL=https://download.osgrid.org/osgrid-opensim-04172026.v0.9.3.ef8a36b.zip \
  -t bithatch/opensim-ai-osgrid:latest \
  -t bithatch/opensim-ai-osgrid:${TAG_DATE} \
  .

docker push bithatch/opensim-ai-osgrid:latest
docker push bithatch/opensim-ai-osgrid:${TAG_DATE}
```

### 6) Compose image selection

The main compose files default to published images and can run without local
build steps.

For local development builds, use the helper scripts. They apply mode-specific
override files:

- `docker-compose.local.yml`
- `docker-compose.release.local.yml`
- `docker-compose.osgrid.local.yml`

Those override files add `build:` sections and keep current local image tags:

- source: `opensim-ai-standalone:dev`
- release: `opensim-ai-standalone:latest`
- osgrid: `opensim-ai-osgrid:latest`

If you need to override published images manually, set one or more of:

- `OPENSIM_SOURCE_IMAGE`
- `OPENSIM_RELEASE_IMAGE`
- `OPENSIM_OSGRID_IMAGE`

## Notes

- The container starts OpenSim with `-background=true` to avoid interactive prompt loops.
- `DefaultEstateOwnerUUID` is set from env so first-run estate owner creation does not block on prompt input.
- Archive handling supports `.zip`, `.tar.gz`, `.tgz` URLs.

## Reset

To wipe persistent data for the active compose stack:

```bash
docker compose down -v
```

For multi-file invocations, use the same `-f ...` arguments when calling `down`.
