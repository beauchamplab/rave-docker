# Docker files for RAVE

Docker creates a "virtual machine" within which other software, such as RAVE, runs. This can be useful if you wish to distribute or create archival copies of RAVE, for instance when uploading data to a repository. It is not recommended for day-to-day (production) usage as performance is worse and usage is more complex, as the virtual machine does not have access to the entire file structure.
For day-to-day use, please install RAVE on your local machine: https://openwetware.org/wiki/RAVE:Install

The RAVE docker image may not be updated as frequently as the main RAVE package so it may not contain the latest features.

## RAVE-within-Docker image installation

First, install Docker on your computer https://www.docker.com/products/docker-desktop
This is not necessary if you already have Docker installed on your local machine or if you are using a cloud Docker service.

Next, open a terminal window and run the following command. The first time it is executed, it will download RAVE software and all dependencies. The total size of the image to be downloaded is around 1GB so the first download may take some time. If RAVE is already downloaded, it will not need to re-download and RAVE will start immediately. 
```
docker run --name rave-docker -p 1111:6767 -e NCPUS=4 beauchamplab/rave start_rave
```
All docker containers must have a unique name (specified with -name) and port # (first value after -p). Docker always uses a fixed port (6767). The port that you specify is forwarded to this port. NCPUS is the number of CPU cores to use for each container instance.

To interact with RAVE, launch a web browser (Google Chrome is recommended) and enter the following address:
```
http://localhost:1111
```
Where "1111" is the port number used above.

## Advanced Docker usage
See this page:https://github.com/beauchamplab/rave-docker/blob/master/Advanced.md
