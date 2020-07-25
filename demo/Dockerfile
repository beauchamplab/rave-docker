# Dockere with demo data and all other things

FROM beauchamplab/rave:devel

## For local test
# FROM rave:devel

COPY start_rave.R /usr/local/bin/start_rave

RUN chmod 777 /usr/local/bin/start_rave

RUN apt-get update -qq \
  && apt-get install -y --no-install-recommends \
  && Rscript --verbose --vanilla -e "devtools::install_github('beauchamplab/rave@dev-raveio', upgrade = FALSE, force = TRUE)" \
  && Rscript --verbose --vanilla -e "devtools::install_github('beauchamplab/raveio', upgrade = FALSE, force = TRUE)"

EXPOSE 6767
EXPOSE 6768
EXPOSE 6769
EXPOSE 6770

CMD ["/usr/local/bin/start_rave"]

# docker run --rm -p 6767:6767 -p 6768:6768 -p 6769:6769 --mount type=bind,source="/Users/beauchamplab/rave_data",target=/data/rave_data -e NCPUS=2 rave:demo

# docker rmi -f $(docker images -a -q)
