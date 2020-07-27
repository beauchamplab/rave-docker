## Advanced Docker usage

## Update container

1. Update docker image first, run *Terminal* app:
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

docker run --name $NAME -p $PORT_MAIN:6767 -v "$RAVE_ROOT":/data/rave_data \
  -e NCPUS=$NCPUS \
  beauchamplab/rave $RAVE_SERVICE
```


## Where's my data?
Answer: check /data/ext, you can use R command list.files('/data/ext') to check them or in the command type

  docker exec -ti <docker_name> ls /data/ext
