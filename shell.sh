#!/usr/bin/env bash
#
# Copyright (C) 2020         Zhengjia Wang
# Released under GPL (>= 3)

# Download or upgrade Docker image
docker pull beauchamplab/rave

# ------------- Global variables ---------------

# Container name, must be unique across instances
CONTAINER_NAME="rave-container-1"


# Service currently only supports start_rave
RAVE_SERVICE=start_rave

# Server port to forward to
PORT_MAIN=6767

# Uncomment this line to enable preprocess service as secondary
# PORT_SECONDARY=6768

# Number of CPU cores to use for RAVE
NCPUS=1

# RAVE folder, should contains
# data_dir/, raw_dir/, cache_dir/ (optional), bids_dir/ (optional)
RAVE_ROOT="/Users/beauchamplab/rave_data"

# Uncomment the following line to specify token (or set the variable before calling the script)
# RAVE_TOKEN="AAA"


# ------------- Initialize instance ---------------
# Don't edit the following lines

if [ -z "$PORT_SECONDARY" ]
then
  second_port=""
else
  second_port=" -p $PORT_SECONDARY:6768"
fi

# start_rave [-n NCPUS] [-t TOKEN]
if [ -z "$RAVE_TOKEN" ]
then
  token=""
else
  token="--token $RAVE_TOKEN"
fi

# Explain:
# -d    Detached mode
# -ti   Interactive (print results in current terminal)
# --name $CONTAINER_NAME  container name
# -p    Forward port
# -v    Mount volume
docker run -it -d --name $CONTAINER_NAME -p $PORT_MAIN:6767$second_port -v "$RAVE_ROOT":/data/rave_data beauchamplab/rave $RAVE_SERVICE --ncpus $NCPUS $token


if [ ! -z "$PORT_SECONDARY" ]
then
  # Start preprocess
  docker exec -d -it $CONTAINER_NAME Rscript --vanilla -e "rave::rave_preprocess(host='0.0.0.0',port=6768,launch.browser=FALSE)"
fi

