# Not only has tools installed
# but also has some dependencies installed to reduce build-time
FROM dipterix/diptools:rave

LABEL org.label-schema.license="GPL-3.0" \
  org.label-schema.vcs-url="https://github.com/beauchamplab/rave" \
  org.label-schema.vendor="Beauchamplab"

COPY finalize_installation.R /usr/local/bin/finalize_installation
COPY start_rave.R /usr/local/bin/start_rave
COPY rave_preprocess.R /usr/local/bin/rave_preprocess

RUN apt-get update -qq \
  && apt-get install -y --no-install-recommends \
  && chmod 777 /usr/local/bin/finalize_installation \
  && chmod 777 /usr/local/bin/start_rave \
  && chmod 777 /usr/local/bin/rave_preprocess

# Enter raveuser to install
RUN useradd -ms /bin/bash -u 1001 raveuser
USER raveuser

RUN mkdir -p /home/raveuser/rave_data/ \
  && chmod 777 /home/raveuser/rave_data/ \
  && Rscript --verbose --no-save -e "dir.create(Sys.getenv('R_LIBS_USER'), showWarnings = FALSE, recursive = TRUE, mode = '0777')" \
  && Rscript --verbose --vanilla -e "rave::check_dependencies(update_rave = FALSE, restart = TRUE, nightly = TRUE)" \
  && finalize_installation

WORKDIR /home/raveuser

EXPOSE 6767
EXPOSE 6768
EXPOSE 6769
EXPOSE 6770

CMD ["/usr/local/bin/start_rave"]

# docker run --rm -p 6767:6767 -p 6768:6768 -p 6769:6769 --mount type=bind,source="/Users/beauchamplab/rave_data",target=/data/rave_data -e NCPUS=4 rave:latest
