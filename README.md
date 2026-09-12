# OpenSim AI Stack

[OpenSim AI Stack](https://opensim-stack.github.io/) is a Docker based container management system along with a suite of purpose built add-on containers built specifically for make it easy to integrate and run [OpenSimulator](http://opensimulator.org/) with Large Language Models and coding frameworks. It also aims to make a pretty good standard grid manager that makes setup a breeze. 

Each component in the stack is managed by a [dedicated controller](https://github.com/opensim-stack/opensim-spawner) with a useful front-end for both administrators and users of your grid.

Run with a single Docker command, or use Docker compose.

*Version 20260912 contains breaking changes, see [CHANGES.md](CHANGES.md)*

## Quick Start

*In all cases replace `myhostname` with whatever hostname you will be using to access both your grid and the web user interface. If your grid is limited to your LAN, your computer name will usually suffice.*

### With Docker

```bash
docker network create opensim-ai_default && docker run -it \
  --restart unless-stopped \
  --pull missing \
  --name opensim-ai-spawner \
  --network opensim-ai_default \
  -v opensim-ai_opensim-config:/config \
  -v opensim-ai_opensim-workspace:/workspace \
  -v opensim-ai_opensim-spawner-data:/data \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -p 8993:8993/tcp \
  -e OPENSIM_HOSTNAME=myhostname \
  bithatch/opensim-spawner:latest
```

*The spawner must be given access to the Docker Socket `/var/run/docker.sock` to be able to function and dynamically provisioning new containers.*

### With Docker Compose

```bash
OPENSIM_HOSTNAME=myhostname docker compose up -d
```

In both cases, open your browser to `http://myhostname:8993`. You will be guided through creating your grid, region, bot and user. By the end, the manager will have created a load more docker containers each with its own task. For example, a 

*See .env.example and copy to .env to tune variables. Beginners should not do  this*

### Alternative Setup Methods

You can also skip the setup wizard and have setup automatically performed based on environment variabls (see `.env.example` near the top).

To start a standalone simulator ..

```bash
OPENSIM_PROVISION_MODE=auto OPENSIM_HOSTNAME=myhostname docker compose up -d
```

Or a ROBUST grid ..

```bash
OPENSIM_PROVISION_MODE=grid OPENSIM_HOSTNAME=myhostname docker compose up -d
```

Or if you are a developer, you might want to run using entirely local images (see `resources/opensim-ai-build.sh`). 

```bash
docker network create opensim-ai_default && docker run -it \
  --restart unless-stopped \
  --pull missing \
  --name opensim-ai-spawner \
  --network opensim-ai_default \
  -v opensim-ai_opensim-config:/config \
  -v opensim-ai_opensim-workspace:/workspace \
  -v opensim-ai_opensim-spawner-data:/data \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -p 8993:8993/tcp \
  -e OPENSIM_HOSTNAME=myhostname \
  -e OPENSIM_GROUP=_ \
  -e OPENSIM_TAG=local \
  opensim-spawner:local
```

.. and the `docker compose` equivalent of this ...

```bash
OPENSIM_SPAWNER_IMAGE=opensim-spawner:local \
OPENSIM_GROUP="_" \
OPENSIM_TAG=local \
OPENSIM_HOSTNAME=myhostname \
docker compose up -d
```

## Access Your 3D World

Login with a [Viewer](https://www.firestormviewer.org/) to (default username is `Bot Handler` and password is `changeme`):

```
http://myhostname:9000
```

## Direct GitHub Files


- [Compose](https://github.com/opensim-stack/opensim-ai-docker/blob/main/docker-compose.yml)
- [Example environment file](https://github.com/opensim-stack/opensim-ai-docker/blob/main/.env.example)

## More Information

See [OpenSim AI Stack](https://opensim-stack.github.io/) and [Documentation](https://opensim-stack.github.io/docs/index.html) for more information.
