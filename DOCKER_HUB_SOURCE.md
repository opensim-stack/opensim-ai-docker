# OpenSim AI Stack - Source Build Type

This image/tag is for the **Source** build type of the OpenSim Stack project.

**OpenSim Stack**: *"A docker stack to get an AI integrated virtual world up and running in minutes."*

Source mode runs OpenSim standalone with MariaDB, plus MCP and web tooling. It is intended for development workflows where you want a source-oriented runtime image/tag.

## Image And Tag

- Repository: `bithatch/opensim-ai-standalone`
- Source tag: `dev-latest`

## Quick Start

Use the source-mode compose stack:

```bash
docker compose up -d
```

Or pull/run by image tag directly:

```bash
docker pull bithatch/opensim-ai-standalone:dev-latest
```

## Project Links

- Main AI Stack (`opensim-ai-docker`): https://github.com/opensim-stack/opensim-ai-docker
- `opensim-metaverse2mcp` on GitHub: https://github.com/opensim-stack/opensim-metaverse2mcp
- `opensim-console2mcp` on GitHub: https://github.com/opensim-stack/opensim-console2mcp
- `opensim-console2mcp` on Docker Hub: https://hub.docker.com/repository/docker/bithatch/opensim-console2mcp/general
