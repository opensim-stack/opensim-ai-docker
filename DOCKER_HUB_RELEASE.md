# OpenSim AI Stack - Release Build Type

This image/tag is for the **Release** build type of the OpenSim Stack project.

**OpenSim Stack**: *"A docker stack to get an AI integrated virtual world up and running in minutes."*

Release mode runs OpenSim standalone with MariaDB, plus MCP and web tooling, using the release-oriented runtime tag.

## Image And Tag

- Repository: `bithatch/opensim-ai-standalone`
- Release tag: `latest`

## Quick Start

Use the release-mode compose stack:

```bash
docker compose -f docker-compose.release.yml up -d
```

Or pull/run by image tag directly:

```bash
docker pull bithatch/opensim-ai-standalone:latest
```

## Project Links

- Main AI Stack (`opensim-ai-docker`): https://github.com/opensim-stack/opensim-ai-docker
- `opensim-metaverse2mcp` on GitHub: https://github.com/opensim-stack/opensim-metaverse2mcp
- `opensim-console2mcp` on GitHub: https://github.com/opensim-stack/opensim-console2mcp
- `opensim-console2mcp` on Docker Hub: https://hub.docker.com/repository/docker/bithatch/opensim-console2mcp/general
