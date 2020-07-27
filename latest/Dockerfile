# Not only has tools installed
# but also has some dependencies installed to reduce build-time
FROM dipterix/diptools:rave

LABEL org.label-schema.license="GPL-3.0" \
  org.label-schema.vcs-url="https://github.com/beauchamplab/rave" \
  org.label-schema.vendor="Beauchamplab"

COPY finalize_installation.R /usr/local/bin/finalize_installation
COPY start_rave.R /usr/local/bin/start_rave

RUN apt-get update -qq \
  && apt-get install -y --no-install-recommends \
  && mkdir -p /data/ \
  && chmod 777 /usr/local/bin/finalize_installation \
  && chmod 777 /usr/local/bin/start_rave \
  && install2.r --error --skipinstalled --deps TRUE docopt \
  && Rscript --verbose --vanilla -e "devtools::install_github('beauchamplab/ravebuiltins', upgrade = FALSE, force = TRUE)" \
  && Rscript --verbose --vanilla -e "devtools::install_github('beauchamplab/rave', upgrade = FALSE, force = TRUE)"

# Temporarily use dev version as master version is too low

RUN Rscript --verbose --vanilla -e "devtools::install_github('beauchamplab/ravebuiltins@migrate2', upgrade = FALSE, force = TRUE)" \
  && Rscript --verbose --vanilla -e "devtools::install_github('beauchamplab/rave@dev-raveio', upgrade = FALSE, force = TRUE)" \
  && Rscript --verbose --vanilla -e "devtools::install_github('beauchamplab/raveio', upgrade = FALSE, force = TRUE)" \
  && Rscript --verbose --vanilla -e "devtools::install_github('dipterix/threeBrain', upgrade = FALSE, force = TRUE)" \
  && Rscript --verbose --vanilla -e "devtools::install_github('dipterix/lazyarray', upgrade = FALSE, force = TRUE)" \
  && Rscript --verbose --vanilla -e "devtools::install_github('dipterix/dipsaus', upgrade = FALSE, force = TRUE)" \
  && finalize_installation

EXPOSE 6767
EXPOSE 6768
EXPOSE 6769
EXPOSE 6770

CMD ["/usr/local/bin/start_rave"]

# docker run --rm -p 6767:6767 -p 6768:6768 -p 6769:6769 --mount type=bind,source="/Users/beauchamplab/rave_data",target=/data/rave_data -e NCPUS=4 rave:latest
