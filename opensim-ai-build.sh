#!/bin/bash

STACK_GIT_BASE="${HOME}/Documents/Git"
PUBLISH=n
TAG=$(date +%Y%m%d)

if [ "$1" == "--publish" ] ; then
	PUBLISH=y
    echo "Full Opensim AI Stack build AND publish"
	docker buildx create --name multiarch --use
	docker buildx inspect --bootstrap
else
    echo "Full Opensim AI Stack build AND publish"
fi
date

# Piper
echo "###########################################"
echo Piper
echo "###########################################"
cd "${STACK_GIT_BASE}/opensim-piper"
if ! docker build -t opensim-piper:local . ; then
	echo "$0: opensim-piper build  failed" >&2
	exit 1
fi
if [ "${PUBLISH}" = "y" ] ; then
	if ! docker buildx build \
		  	--platform linux/amd64,linux/arm64 \
		  -t bithatch/opensim-piper:latest \
		  -t bithatch/opensim-piper:${TAG} \
		  --push \
		  . ; then
		echo "$0: opensim-piper publish failed" >&2
		exit 1
	fi
fi

# Opencode
echo "###########################################"
echo Opencode
echo "###########################################"
cd "${STACK_GIT_BASE}/opensim-opencode"
if ! docker build -t opensim-opencode:local . ; then
	echo "$0: opensim-opencode build  failed" >&2
	exit 1
fi
if [ "${PUBLISH}" = "y" ] ; then
	if ! docker buildx build \
		  	--platform linux/amd64,linux/arm64 \
		  -t bithatch/opensim-opencode:latest \
		  -t bithatch/opensim-opencode:${TAG} \
		  --push \
		  . ; then
		echo "$0: opensim-opencode publish failed" >&2
		exit 1
	fi
fi

# Blender
echo "###########################################"
echo "Blender (AMD64 only)"
echo "###########################################"
cd "${STACK_GIT_BASE}/opensim-blender"
if ! docker build -t opensim-blender:local . ; then
	echo "$0: opensim-blender build  failed" >&2
	exit 1
fi
if [ "${PUBLISH}" = "y" ] ; then
	if ! docker buildx build \
		  	--platform linux/amd64 \
		  -t bithatch/opensim-blender:latest \
		  -t bithatch/opensim-blender:${TAG} \
		  --push \
		  . ; then
		echo "$0: opensim-blender publish failed" >&2
		exit 1
	fi
fi

# Console2MCP
echo "###########################################"
echo "Console2MCP"
echo "###########################################"
cd "${STACK_GIT_BASE}/opensim-console2mcp"
if ! docker build -t opensim-console2mcp:local . ; then
    echo "$0: opensim-console2mcp build  failed" >&2
    exit 1
fi
if [ "${PUBLISH}" = "y" ] ; then
    if ! docker buildx build \
            --platform linux/amd64,linux/arm64 \
          -t bithatch/opensim-console2mcp:latest \
          -t bithatch/opensim-console2mcp:${TAG} \
          --push \
          . ; then
        echo "$0: opensim-console2mcp publish failed" >&2
        exit 1
    fi
fi

# Metaverse2MCP
echo "###########################################"
echo "Metaverse2MCP"
echo "###########################################"
cd "${STACK_GIT_BASE}/opensim-metaverse2mcp"
if ! docker build -t opensim-metaverse2mcp:local . ; then
    echo "$0: opensim-metaverse2mcp build  failed" >&2
    exit 1
fi
if [ "${PUBLISH}" = "y" ] ; then
    if ! docker buildx build \
            --platform linux/amd64,linux/arm64 \
          -t bithatch/opensim-metaverse2mcp:latest \
          -t bithatch/opensim-metaverse2mcp:${TAG} \
          --push \
          . ; then
        echo "$0: opensim-metaverse2mcp publish failed" >&2
        exit 1
    fi
fi

# Spawner
echo "###########################################"
echo "Spawner"
echo "###########################################"
cd "${STACK_GIT_BASE}/opensim-spawner"
if ! docker build -t opensim-spawner:local . ; then
    echo "$0: opensim-spawner build  failed" >&2
    exit 1
fi
if [ "${PUBLISH}" = "y" ] ; then
    if ! docker buildx build \
            --platform linux/amd64,linux/arm64 \
          -t bithatch/opensim-spawner:latest \
          -t bithatch/opensim-spawner:${TAG} \
          --push \
          . ; then
        echo "$0: opensim-spawner publish failed" >&2
        exit 1
    fi
fi

# 
# 
#
echo "###########################################"
echo "Open Simulator AI Standalone"
echo "###########################################"
 
cd "${STACK_GIT_BASE}/opensim-ai-docker"

if [ "${PUBLISH}" = "y" ] ; then
    if ! docker build \
      --target source-runtime \
      --build-arg OPENSIM_GIT_URL=git://opensimulator.org/git/opensim \
      --build-arg OPENSIM_GIT_REF=master \
      -t bithatch/opensim-ai-standalone:dev-latest \
      -t bithatch/opensim-ai-standalone:dev-${TAG} \
      . \
      || \
      ! docker push bithatch/opensim-ai-standalone:dev-latest \
      || \
      ! docker push bithatch/opensim-ai-standalone:dev-${TAG} ; then
        echo "$0: opensim-ai-standalone dev publish failed" >&2
        exit 1q
    fi
    
    if ! docker build \
      --target release-runtime \
      --build-arg OPENSIM_RELEASE_REF=r78cb44c \
      --build-arg OPENSIM_RELEASE_URL=https://github.com/opensim/opensim/releases/download/r78cb44c/LastDotNetBuild.zip \
      -t bithatch/opensim-ai-standalone:latest \
      -t bithatch/opensim-ai-standalone:${TAG_DATE} \
      . \
      || \
      ! docker push bithatch/opensim-ai-standalone:latest \
      || \
      ! docker push bithatch/opensim-ai-standalone:${TAG_DATE} ; then
        echo "$0: opensim-ai-standalone publish failed" >&2
        exit 1
    fi
fi


echo "###########################################"
echo "Done!"
date
echo "###########################################"
