# Docker files for RAVE

Docker creates a "virtual machine" within which other software, such as RAVE, runs. This can be useful if you wish to distribute or create archival copies of RAVE, for instance when uploading data to a repository. It is not recommended for day-to-day (production) usage as performance is worse and usage is more complex, as the virtual machine does not have access to the entire file structure.
For day-to-day use, please install RAVE on your local machine: https://openwetware.org/wiki/RAVE:Install


## RAVE-within-Docker image installation

First, install Docker on your computer [link]https://www.docker.com/products/docker-desktop
This is not necessary if you already have Docker installed on your local machine or if you are using a cloud Docker service.
Next, open a terminal window and assign the following environment variables. The syntax for assigning variables may differ across shells.
```NAME=rave-docker
RAVE_SERVICE=start_rave
PORT_MAIN=1111
NCPUS=4
```

These values can change:
NAME: Container's name (must be unique)
2. `<RAVE_SERVICE>`: Services to run (currectly only `start_rave` is supported)
2. `<PORT_MAIN>`: Port to run main application
3. `<NCPUS>`: Number of CPU cores to use for each container instances
4. `<RAVE_ROOT>`: RAVE folder 

The total size of the image to be downloaded is around 1GB.

To start, please open *Terminal* and assign the following variables


Run the following command, replacing variables with your values
```
# Assign variables, replace your settings here


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



## RAVE-within-Docker in the cloud

For this use case, you may wish to give RAVE-within-Docker access to other directories on your machine. In this case, you must give Docker the directory that you want them to give access to:
RAVE_ROOT=/Volumes/data/rave_data

