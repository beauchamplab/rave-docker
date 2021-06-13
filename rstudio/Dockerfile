FROM beauchamplab/rave:latest

ARG RSTUDIO_VERSION

# Install RStudio server from scratch (supports ARM)
USER root
WORKDIR /tmp/
EXPOSE 8787/tcp

  # Configure user
RUN useradd -r rstudio-server \
  && useradd -ms /bin/bash -u 1001 raveuser \
  && groupadd rstudio-user \
  && mkdir /etc/rstudio/ \
  && touch /etc/rstudio/rserver.conf \
  && touch /etc/rstudio/rsession.conf \
  && echo "www-port=8787" >> /etc/rstudio/rserver.conf \
  && echo "www-address=0.0.0.0" >> /etc/rstudio/rserver.conf \
  && echo "session-timeout-minutes=0" >> /etc/rstudio/rsession.conf \
  && usermod -a -G docker raveuser \
  && usermod -a -G sudo raveuser \
  && usermod -a -G rstudio-user raveuser \
  && usermod --password ravepwd raveuser
RUN apt-get update -qq \
  && apt-get install -y \
    ant \
    bzip2 \
    ca-certificates curl clang cmake \
    debsigs dpkg-sig \
    expect \
    fakeroot \
    gcc git gnupg1 \
    lsof libcap2 libsqlite3-dev libxml2-dev locales \
    libcurl4-openssl-dev libcap-dev libffi-dev libglib2.0-dev libpam0g-dev \
    libpango-1.0-0 libpq-dev libssl-dev libuser1-dev \
    libacl1-dev libattr1-dev libboost-all-dev libxml-commons-external-java \
    make mesa-common-dev \
    npm \
    openjdk-11-jdk \
    pandoc patchelf python \
    rrdtool \
    uuid-dev \
    vim \
    wget \
    zlib1g \
  # Install rs-server
  && [ -z "$RSTUDIO_VERSION" ] && RSTUDIO_VERSION="v1.4.1106" || true \
  && wget -O $RSTUDIO_VERSION https://github.com/rstudio/rstudio/tarball/$RSTUDIO_VERSION \
  && mkdir /tmp/rstudio \
  && tar xvf /tmp/$RSTUDIO_VERSION -C /tmp/rstudio --strip-components 1 \
  && rm $RSTUDIO_VERSION \
  && echo "Installing RStudio-server from scratch..." \
  && cd /tmp/rstudio/ \
  && mkdir -p /opt/rstudio-tools/panmirror \
  && cp src/gwt/panmirror/src/editor/yarn.lock /opt/rstudio-tools/panmirror/ \
  && cp src/gwt/panmirror/src/editor/package.json /opt/rstudio-tools/panmirror/ \
  && cd /tmp/rstudio/dependencies/common \
  && ./install-dictionaries \
  && ./install-mathjax \
  && ./install-sentry-cli \
  && ./install-pandoc \
  && ./install-npm-dependencies \
  && ./install-packages & \
  && ./install-boost \
  && ./install-soci \
  && cd /tmp/rstudio \
  && mkdir build \
  && cmake -DRSTUDIO_TARGET=Server -DCMAKE_BUILD_TYPE=Release \
  && make install \
  && cp /usr/local/lib/rstudio-server/extras/init.d/debian/rstudio-server /etc/init.d/rstudio-server \
  && chmod +x /etc/init.d/rstudio-server \
  && ln -f -s /usr/local/lib/rstudio-server/bin/rstudio-server /usr/sbin/rstudio-server \
  && systemctl enable rstudio-server \
  && rm -rf /tmp/rstudio \
  && rm -rf /opt/rstudio-tools/depot_tools/ \
  && rm -rf /opt/rstudio-tools/soci/ \
  && rm -rf /opt/rstudio-tools/boost/ \
  && apt autoremove -y pandoc libboost-all-dev \
  && apt-get autoremove -y \
  && /etc/init.d/rstudio-server start \
  && rstudio-server stop \
  && rstudio-server verify-installation \
  && rstudio-server start

CMD ["/usr/local/bin/start_rave"]

# docker run --rm -p 6767:6767 -p 6768:6768 -p 6769:6769 --mount type=bind,source="/Users/beauchamplab/rave_data",target=/data/rave_data -e NCPUS=4 rave:latest
# docker build --pull --tag rave:latest ./devel

