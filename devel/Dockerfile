FROM beauchamplab/rave:latest

RUN apt-get update -qq \
  && apt-get install -y --no-install-recommends \
  && mkdir -p /data/ \
  && Rscript --verbose --vanilla -e "devtools::install_github('beauchamplab/ravebuiltins@migrate2', upgrade = FALSE, force = TRUE)" \
  && Rscript --verbose --vanilla -e "devtools::install_github('beauchamplab/rave@dev-raveio', upgrade = FALSE, force = TRUE)" \
  && Rscript --verbose --vanilla -e "devtools::install_github('dipterix/threeBrain', upgrade = FALSE, force = TRUE)" \
  && Rscript --verbose --vanilla -e "devtools::install_github('dipterix/lazyarray', upgrade = FALSE, force = TRUE)" \
  && Rscript --verbose --vanilla -e "devtools::install_github('dipterix/dipsaus', upgrade = FALSE, force = TRUE)"
