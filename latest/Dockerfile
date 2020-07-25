FROM dipterix/diptools:latest

LABEL maintainer="Beauchamplab <beauchamplab@gmail.com>" \
  org.label-schema.license="GPL-3.0" \
  org.label-schema.vcs-url="https://github.com/beauchamplab/rave" \
  org.label-schema.vendor="Beauchamplab"

COPY finalize_installation.R /usr/local/bin/finalize_installation
COPY start_rave.R /usr/local/bin/start_rave

RUN apt-get update -qq \
  && apt-get install -y --no-install-recommends \
  && chmod 777 /usr/local/bin/finalize_installation \
  && chmod 777 /usr/local/bin/start_rave \
  && install2.r --error --skipinstalled --deps TRUE docopt \
  && Rscript --verbose --vanilla -e "devtools::install_github('beauchamplab/ravebuiltins', upgrade = FALSE, force = TRUE)" \
  && Rscript --verbose --vanilla -e "devtools::install_github('beauchamplab/rave', upgrade = FALSE, force = TRUE)"

EXPOSE 6767

## automatically link a shared volume for kitematic users
VOLUME /home/rstudio/kitematic


