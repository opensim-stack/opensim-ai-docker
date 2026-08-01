# OpenSim AI Stack - OpenSim Image

This Docker Hub page covers the standalone OpenSim image used by the OpenSim Stack project.

**OpenSim Stack**: *"A docker stack to get an AI integrated virtual world up and running in minutes."*

OpenSim mode runs OpenSim standalone with MariaDB, plus MCP and web tooling.

## Image And Tags

- Repository: `bithatch/opensim-ai-standalone`
- Release tag: `latest` (release build type)
- Dev tag: `dev-latest` (source/dev build type)

## Quick Start

Run release mode:

```bash
docker compose -f docker-compose.release.yml up -d
```

Run source/dev mode:

```bash
docker compose up -d
```

Or pull by tag directly:

```bash
docker pull bithatch/opensim-ai-standalone:latest
docker pull bithatch/opensim-ai-standalone:dev-latest
```

## Project Links

- Main AI Stack (`opensim-ai-docker`): https://github.com/opensim-stack/opensim-ai-docker
- `opensim-metaverse2mcp` on GitHub: https://github.com/opensim-stack/opensim-metaverse2mcp
- `opensim-console2mcp` on GitHub: https://github.com/opensim-stack/opensim-console2mcp
- `opensim-console2mcp` on Docker Hub: https://hub.docker.com/repository/docker/bithatch/opensim-console2mcp/general
