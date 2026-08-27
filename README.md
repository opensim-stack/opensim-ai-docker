# OpenSim AI Stack - Docker Compose

A docker compose for starting [OpenSim AI Stack](https://opensim-stack.github.io/).

## Quick Start

Run:

```bash
cd opensim-ai-docker
./run.sh myhostname
```

or setup manually ..

```bash
cp .env.example .env
./generate-janus-tokens.sh # If you want Voice support
OPENSIM_HOSTNAME=myhostname docker compose up -d
```

or Browse to (default username is `ConsoleUser` and password is `ConsolePass`). You will be guided through creating your grid, region, bot and user. 

```
http://myhostname:8993
```

### Alternative Setup Methods

You can also skip the setup wizard and have setup automatically performed based on environment variabls (see `.env.example` near the top).

To start a standalone simulator ..

```
OPENSIM_PROVISION_MODE=auto OPENSIM_HOSTNAME=myhostname docker compose up -d
```

Or a ROBUST grid ..

```
OPENSIM_PROVISION_MODE=grid OPENSIM_HOSTNAME=myhostname docker compose up -d
```

## Access Your 3D World

Login with a [Viewer](https://www.firestormviewer.org/) to (default username is `Bot Handler` and password is `changeme`):

```
http://myhostname:9000
```

## When You Are Done

Bring down:

```bash
docker compose down
```

*Or if you want to completely wipe configuration and data ...*

```
docker compose down -v
```

## Direct GitHub Files

- [Source mode compose](https://github.com/opensim-stack/opensim-ai-docker/blob/main/docker-compose.source.yml)
- [Release mode compose](https://github.com/opensim-stack/opensim-ai-docker/blob/main/docker-compose.yml)
- [Example environment file](https://github.com/opensim-stack/opensim-ai-docker/blob/main/.env.example)
