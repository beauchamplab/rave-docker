FROM dipterix/diptools:devel

LABEL maintainer="Beauchamplab <beauchamplab@gmail.com>" \
  org.label-schema.license="GPL-3.0" \
  org.label-schema.vcs-url="https://github.com/beauchamplab/rave" \
  org.label-schema.vendor="Beauchamplab"

RUN apt-get update -qq \
  && apt-get install -y --no-install-recommends \
  && Rscript --verbose --vanilla -e "devtools::install_github('beauchamplab/ravebuiltins', upgrade = FALSE, force = TRUE)" \
  && Rscript --verbose --vanilla -e "devtools::install_github('beauchamplab/rave', upgrade = FALSE, force = TRUE)"
