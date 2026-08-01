# OpenSim AI Stack - OSGrid Build Type

This image is for the **OSGrid** build type of the OpenSim Stack project.

**OpenSim Stack**: *"A docker stack to get an AI integrated virtual world up and running in minutes."*

OSGrid mode includes Hypergrid-ready setup and generates region config from required `OSGRID_*` variables.

## Image And Tag

- Repository: `bithatch/opensim-ai-osgrid`
- Tag: `latest`

## Quick Start

Use the OSGrid compose stack:

```bash
docker compose -f docker-compose.osgrid.yml up -d
```

Before first run, set required variables in `.env`:

- `OSGRID_REGION_NAME`
- `OSGRID_REGION_UUID`
- `OSGRID_REGION_LOCATION`
- `OSGRID_EXTERNAL_HOSTNAME`

Or pull/run by image tag directly:

```bash
docker pull bithatch/opensim-ai-osgrid:latest
```

## Project Links

- Main AI Stack (`opensim-ai-docker`): https://github.com/opensim-stack/opensim-ai-docker
- `opensim-metaverse2mcp` on GitHub: https://github.com/opensim-stack/opensim-metaverse2mcp
- `opensim-console2mcp` on GitHub: https://github.com/opensim-stack/opensim-console2mcp
- `opensim-console2mcp` on Docker Hub: https://hub.docker.com/repository/docker/bithatch/opensim-console2mcp/general
