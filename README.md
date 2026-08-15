# OpenSimulator Docker Stack with AI Experiments

[![Docker Hub Standalone](https://img.shields.io/badge/Docker%20Hub-bithatch%2Fopensim--ai--standalone-2496ED?logo=docker&logoColor=white)](https://hub.docker.com/repository/docker/bithatch/opensim-ai-standalone/general)

A Docker stack for OpenSimulator and OS Grid that makes it easy to setup an AI enabled virtual world.

This is done by integrating [opensim-console2mcp](https://github.com/opensim-stack/opensim-console2mcp), [opensim-metaverse2mcp](https://github.com/opensim-stack/opensim-metaverse2mcp), [opensim-opencode](https://github.com/opensim-stack/opensim-opencode) and [opensim-blender](https://github.com/opensim-stack/opensim-blender) as part of the stack. `opensim-console2mcp` bridges the OpenSimulator REST console to MCP, `opensim-metaverse2mcp` provides a bridge to a bot controlled by MCP, `opensim-opencode` runs Opencode in server mode preconfigured to use those MCP bridges, and `opensim-blender` runs a headless Blender instance with the Blender MCP add-on for 3D modelling tasks.

 * Manage your OpenSimulator server using natural language. Anything that the console can do, your AI can do including region management, user management, configuration and lots more.
 * Start a conversation with the AI bot to start giving it any instructions you like
 * Bot can walk, run or fly to any point in the region, or teleport to others.
 * Bot can create, position, scale, rotate and texture prims.
 * Bot can create and configure your environment settings.
 * Bot can inspect inventories, send and copy items and more.
 * Bot can download and upload media of all types.
 * Blender MCP add-on lets the AI create and edit 3D models in the shared `/workspace`, exporting to glTF for use in-world.

## A Warning - This Is Work In Progress

*This is all very experimental! Do not let the bot lose on anything you care about! Take backups of your regions*

*I am actively working on this! It may change ports, volumes or other behaviour. Once you have a working version, I recommend pinning that version and monitoring updates!*

### Temporary Limitations

 * The can currently only be a single bot
 * The bot can only exist on a single region

## Quick Start

 1. Install the entire Opensim AI stack using Docker Compose. I recommend starting with [docker-compose.release.yml](docker-compose.release.yml). Use [.env.example](.env.example) for the basis of your environment variables. Hopefully your Docker front end will just let you copy the  whole lot in one go! ([Arcane](https://getarcane.app/) does). However, you **MUST** set at least `OPENSIM_HOSTNAME` or it will not work on anything other than `localhost``.
 2. Configure the AI provider and model. [TODO - AI configuration](ai-configuration)
 2. Get yourself an Opensimulator viewer, I recommend [Firestorm](https://www.firestormviewer.org/). Connect to your new personal Grid using `Admin User` and `changeme` (assuming you haven't changed `OPENSIM_ESTATE_OWNER_FIRST`, `OPENSIM_ESTATE_OWNER_FIRST` or `OPENSIM_ESTATE_OWNER_PASSWORD`).
 3. When you login, you will see `Bot User` standing near you. Start an IM conversation with them, and give them an instruction, e.g. 
 
 ```
 Place a cube prim 2 meters away and scale it x2. 
 ```
 
You can  choose a different model and/or provider. For example, to hook up to Github Copilot and use GPT-5.3 Codex, tell the bot ..
 
 1. `*auth methods github-copilot`
 2. `*auth github-copilot oauth 0`
 3. Complete browser/device step
 4. `*auth github-copilot oauth-complete 0`
 5. `*configure github-copilot/gpt-5.3-codex`
 
 For information on other providers and *star commands*, see [opensim-metaverse2mcp/README.md](https://github.com/opensim-stack/opensim-metaverse2mcp). 

## Build Types

1. Source mode: default to published source image; optionally build from git via local override.
2. Release mode: default to published release image; optionally build from official binary archive.

*Note: security defaults are intentionally lax and mainly suitable for local use. All components support proper authentication, so you should replace default credentials before exposing services externally.*

## Files

- Dockerfile
- docker-compose.yml (source mode default)
- docker-compose.release.yml (official binary release override)
- docker-compose.local.yml (local source build override)
- docker-compose.release.local.yml (local release build override)
- .env.example
- docker/init-standalone.sh
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

Each script will auto-create `.env` from `.env.example` if it does not exist.

By default, compose files use published images via these variables:

- `OPENSIM_SOURCE_IMAGE` (default `bithatch/opensim-ai-standalone:dev-latest`)
- `OPENSIM_RELEASE_IMAGE` (default `bithatch/opensim-ai-standalone:latest`)
- `OPENSIM_METAVERSE2MCP_IMAGE` (default `bithatch/opensim-metaverse2mcp:latest`)
- `OPENSIM_BLENDER_IMAGE` (default `bithatch/opensim-blender:latest`)

The helper scripts use local override compose files (`docker-compose.*.local.yml`) to
build and run local images with the current local tags.

Use cases:

- Use plain `docker compose ... up -d` to run published images.
- Use `./run.sh` or `./run-release.sh` for local builds.

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

## OpenSim Blender MCP Server (opensim-blender)

This stack also runs a headless Blender sidecar using
`bithatch/opensim-blender:latest`.

The container starts Blender with the upstream
[ahujasid/blender-mcp](https://github.com/ahujasid/blender-mcp) add-on.
Because upstream runs MCP over stdio (not native HTTP), the image also runs an
in-container MCP proxy so the stack can connect over HTTP on port `8996`.

Default endpoint inside the stack:

- `http://opensim-blender:8996/mcp`

Environment variables:

- `OPENSIM_BLENDER_IMAGE`
- `BLENDER_MCP_HOST` (default `0.0.0.0`)
- `BLENDER_MCP_PORT` (default `8996`)
- `BLENDER_TCP_PROTOCOL_HOST` (default `127.0.0.1`)
- `BLENDER_TCP_PROTOCOL_PORT` (default `9876`)
- `BLENDER_PROJECT_DIR` (default `/workspace`)
- `BLENDER_EXTRA_ARGS`

Legacy compatibility aliases still accepted by the image:

- `BLENDER_BRIDGE_HOST` -> `BLENDER_TCP_PROTOCOL_HOST`
- `BLENDER_BRIDGE_PORT` -> `BLENDER_TCP_PROTOCOL_PORT`

Volume mappings:

- `opensim-workspace` -> `/workspace`
- `blender-config` -> `/root/.config/blender`
- `blender-cache` -> `/root/.cache/blender`
- `blender-data` -> `/root/.local/share/blender`

The shared workspace lets Opencode and Blender exchange project files. Models can
be exported from Blender as glTF (`.glb`/`.gltf`) and then uploaded into the
OpenSim world via the metaverse bot.

## OpenSim Metaverse MCP Server (opensim-metaverse2mcp)

This project also runs a bot-side MCP service using
`bithatch/opensim-metaverse2mcp:latest`.

The service logs in a bot avatar and exposes in-world tools (movement, prim and
environment actions) over MCP HTTP.

Mount layout used by the stack:

- Shared generated config is mounted at `/templates`.
- Region files are mounted via a dedicated regions volume:
  - OpenSim runtime: `/opt/opensim/bin/Regions`
  - Init container generation target: `/regions`
  - Opencode sidecar visibility: `/regions`

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
- `OPENCODE_CHAT_ENABLED`
- `OPENCODE_SCHEME`
- `OPENCODE_CHAT_HOST` (mapped to `OPENCODE_HOST` inside `opensim-metaverse2mcp`)
- `OPENCODE_CHAT_PORT` (mapped to `OPENCODE_PORT` inside `opensim-metaverse2mcp`)
- `OPENCODE_USERNAME`
- `OPENCODE_PASSWORD` (falls back to `OPENCODE_SERVER_PASSWORD`)
- `OPENCODE_INITIAL_PROVIDER` (optional startup default provider for IM conversations; runtime-overridable)
- `OPENCODE_INITIAL_MODEL` (optional startup default model for IM conversations; runtime-overridable)
- `OPENCODE_REQUEST_TIMEOUT_SECONDS`
- `OPENCODE_HANDLER_FIRSTNAME` (optional; defaults to `OPENSIM_ESTATE_OWNER_FIRST`)
- `OPENCODE_HANDLER_LASTNAME` (optional; defaults to `OPENSIM_ESTATE_OWNER_LAST`)
- `OPENCODE_LSL_DIALOG_BRIDGE_TRUSTED_OWNER_ID` (optional; trusted bridge object owner UUID)
- `OPENCODE_LSL_DIALOG_BRIDGE_TRUSTED_OBJECT_ID` (optional; trusted bridge object UUID)
- `OPENCODE_LSL_DIALOG_BRIDGE_REQUIRE_TRUSTED_SENDER` (`true`/`false`, default: `true`)
- `PROMPT_HANDLING_ENABLED`
- `PROMPT_PROJECT_AGENTS_ENABLED`
- `PROMPT_PROJECT_AGENTS_FILE` (default in this stack: `/app/AGENTS.md`)
- `PROMPT_NOTECARD_REQUIRE_HANDLER`

Default endpoint inside the stack:

- `http://opensim-metaverse2mcp:8999/mcp`

Bot bootstrap behavior:

- `OPENSIM_CREATE_BOT_USER=true` adds a startup console command that creates the
  bot user using `OPENSIM_LOGIN_FIRSTNAME`, `OPENSIM_LOGIN_LASTNAME`,
  `OPENSIM_LOGIN_PASSWORD`, `OPENSIM_LOGIN_EMAIL`, `OPENSIM_LOGIN_UUID`, and
  `OPENSIM_LOGIN_MODEL`.
- If `OPENSIM_LOGIN_UUID` is blank, init generates a UUID automatically.
- Set `OPENSIM_LOGIN_MODEL` to `""` if you want an empty model/avatar template.
- Handler behavior: by default, the metaverse bot only accepts IM instructions from the estate owner name (`OPENSIM_ESTATE_OWNER_FIRST` + `OPENSIM_ESTATE_OWNER_LAST`) unless you override `OPENCODE_HANDLER_FIRSTNAME` / `OPENCODE_HANDLER_LASTNAME`.

Prompt bootstrap behavior:

- This repository ships a stack-level `AGENTS.md` prompt file in `docker`.
- Compose mounts that file into `opensim-metaverse2mcp` at `/app/AGENTS.md` and sets `PROMPT_PROJECT_AGENTS_FILE=/app/AGENTS.md` by default.
- You can edit `AGENTS.md` to tune assistant behavior without rebuilding images.

Dialog bridge bootstrap behavior:

- `DialogBridgeInstall` auto-discovers the in-image script at `lsl/dialog-bridge.lsl` (runtime path: `/app/lsl/dialog-bridge.lsl`) when `scriptSource` is omitted.

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

- Server port: `8998` (`OPENCODE_PORT`)
- MCP endpoint URL for Opencode: `http://opensim-console2mcp:8997/mcp` (`OPENCODE_MCP_URL`)
- Metaverse MCP endpoint URL for Opencode: `http://opensim-metaverse2mcp:8999/mcp` (`OPENCODE_METAVERSE_MCP_URL`)
- Blender MCP endpoint URL for Opencode: `http://opensim-blender:8996/mcp` (`OPENCODE_BLENDER_MCP_URL`)
- MCP auth: none by default
- Host bind: `0.0.0.0` (`OPENCODE_HOST`)
- Server password pass-through: `OPENCODE_SERVER_PASSWORD`
- Project directory: `/workspace` (`OPENCODE_PROJECT_DIR`)

At startup, an init container writes `opencode.json` into the shared workspace
volume so Opencode is preconfigured to use the MCP sidecars and enforce a
stack-level permission baseline.

Generated config content:

```json
{
  "$schema": "https://opencode.ai/config.json",
  "permission": {
    "read": "allow",
    "write": {
      "/workspace/**": "ask",
      "/config/**": "ask",
      "*": "deny"
    },
    "edit": {
      "/workspace/**": "ask",
      "/config/**": "ask",
      "*": "deny"
    },
    "bash": "ask",
    "external_directory": {
      "/workspace": "allow",
      "/workspace/*": "allow",
      "/config": "ask",
      "/config/*": "ask",
      "/root/.local/share/opencode/tool-output": "allow",
      "/root/.local/share/opencode/tool-output/*": "allow",
      "*": "deny"
    }
  },
  "mcp": {
    "local_host_mcp": {
      "type": "remote",
      "url": "http://opensim-console2mcp:8997/mcp",
      "enabled": true
    },
    "metaverse_mcp": {
      "type": "remote",
      "url": "http://opensim-metaverse2mcp:8999/mcp",
      "enabled": true
    },
    "blender_mcp": {
      "type": "remote",
      "url": "http://opensim-blender:8996/mcp",
      "enabled": true
    }
  }
}
```

Permission behavior in this stack:

- Read access is allowed.
- File write/edit and shell command execution are interactive (ask).
- Paths outside `/workspace` and `/config` are denied by default, except
  Opencode tool-output paths needed for truncated tool logs.

Volume mappings used by the service:

- Source/release stacks:
  - `opensim-workspace` -> `/workspace`
  - `opensim-config` -> `/config`
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

### 5) Compose image selection

The main compose files default to published images and can run without local
build steps.

For local development builds, use the helper scripts. They apply mode-specific
override files:

- `docker-compose.local.yml`
- `docker-compose.release.local.yml`

Those override files add `build:` sections and keep current local image tags:

- source: `opensim-ai-standalone:dev`
- release: `opensim-ai-standalone:latest`
- console MCP: `opensim-console2mcp:latest`
- metaverse MCP: `opensim-metaverse2mcp:latest`
- blender: `opensim-blender:latest`

If you need to override published images manually, set one or more of:

- `OPENSIM_SOURCE_IMAGE`
- `OPENSIM_RELEASE_IMAGE`
- `OPENSIM_BLENDER_IMAGE`

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