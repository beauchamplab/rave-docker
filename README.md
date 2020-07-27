# Docker files for RAVE

Provides cross-platform and portable Docker containers for RAVE. RAVE Docker images are designed to be scalable for cloud services, not recommended for individual uses. Please go to [https://openwetware.org/wiki/RAVE:Install](https://openwetware.org/wiki/RAVE:Install) for installation on local drive.

## Docker image installation

You will need either `Docker-Desktop` ([link](https://www.docker.com/products/docker-desktop)), or a cloud service with Docker support before installation. The total size of the image to be downloaded is around 1GB.

To start, please open *Terminal* and assign the following variables
1. `<NAME>`: Container's name (must be unique)
2. `<RAVE_SERVICE>`: Services to run (currectly only `start_rave` is supported)
2. `<PORT_MAIN>`: Port to run main application
3. `<NCPUS>`: Number of CPU cores to use for each container instances
4. `<RAVE_ROOT>`: RAVE folder 

Run the following command, replacing variables with your values
```
# Assign variables, replace your settings here
NAME=<NAME>
RAVE_SERVICE=<RAVE_SERVICE>
PORT_MAIN=<PORT_MAIN>
NCPUS=<NCPUS>
RAVE_ROOT=<RAVE_ROOT>

# The will download the RAVE software and all dependencies, including the R language, and then start RAVE. If already downloaded, will start RAVE immediately. 
docker run --name $NAME \
  -p $PORT_MAIN:6767 \
  -v "$RAVE_ROOT":/data/rave_data \
  -e NCPUS=$NCPUS \
  beauchamplab/rave $RAVE_SERVICE
```

For example, to start a service `NAME="rave-main-beauchamplab"` running RAVE main application (`RAVE_SERVICE=start_rave`) at local port 8080 (`PORT_MAIN=8080`) with 4 cores (`NCPUS=4`), if RAVE data folder is stored at `/Users/Beauchamplab/rave_data`, then the following command is used.

```
NAME="rave-main-beauchamplab"
RAVE_SERVICE=start_rave
PORT_MAIN=8080
NCPUS=4
RAVE_ROOT="/Users/Beauchamplab/rave_data"

docker run --name $NAME \
  -p $PORT_MAIN:6767 \
  -v "$RAVE_ROOT":/data/rave_data \
  -e NCPUS=$NCPUS \
  beauchamplab/rave $RAVE_SERVICE
```

We highly recommend that you store your commands as *shell* scripts in case you want to update the container in the future.

If the container is initialized for the first time, there might be some downloading procedures in the background (such as demo data and some template files). However, you should be able to view the application at [http://localhost:<PORT_MAIN>](http://localhost:8080) in your browsers.


## Update container

1. Update docker image first, runn *Terminal* app:
```
docker pull beauchamplab/rave
```

2. Stop and remove previous containers. For example, if container called `rave-main-beauchamplab` can be stopped and removed via terminal command
```
docker stop "rave-main-beauchamplab"
docker rm "rave-main-beauchamplab"
```

3. Re-instantiate container. Go to previous section (Docker image installation) to re-install container. 


## Docker resource management

RAVE benefits from multi-core CPUs. However, the more CPUs are used, the more RAM is needed. The scale-up or scale-down the containers, please see [docker-document](https://docs.docker.com/config/containers/resource_constraints/). The recommended resources for RAVE per service type is:
* `start_rave`: 4GB RAM/CPU-core
* `rave_preprocess` (under construction, not supported right now): at least 8GB~10GB RAM/CPU-core



