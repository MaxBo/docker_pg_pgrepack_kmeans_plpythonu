#--------- Generic stuff all our Dockerfiles should start with so we get caching ------------
ARG DISTRO=debian
ARG IMAGE_VERSION=buster
ARG IMAGE_VARIANT=slim
FROM kartoza/postgis:$DISTRO-$IMAGE_VERSION-$IMAGE_VARIANT
MAINTAINER Max Bohnet<bohnet@ggr-planung.de>

# Reset ARG for version
ARG IMAGE_VERSION
ARG POSTGRES_MAJOR_VERSION=13
ARG POSTGIS_MAJOR=3


RUN set -eux \
    && export DEBIAN_FRONTEND=noninteractive \
    && apt-key adv --keyserver hkp://pool.sks-keyservers.net:80 --recv-keys 6BB3BABB751F80D7 \
    && apt-get upgrade;apt-get update \
    && sh -c "echo \"deb http://apt.postgresql.org/pub/repos/apt/ ${IMAGE_VERSION}-pgdg main\" > /etc/apt/sources.list.d/pgdg.list" \
    && wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc -O- | apt-key add - \
    && apt-get -y --purge autoremove \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && dpkg-divert --local --rename --add /sbin/initctl


#-------------Application Specific Stuff ----------------------------------------------------

# We add postgis as well to prevent build errors (that we dont see on local builds)
# on docker hub e.g.
# The following packages have unmet dependencies:

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      wget ca-certificates

RUN set -eux \
    && export DEBIAN_FRONTEND=noninteractive \
    &&  apt-get update \
    && apt-get -y --no-install-recommends install postgresql-client-${POSTGRES_MAJOR_VERSION} \
        postgresql-common postgresql-${POSTGRES_MAJOR_VERSION} \
        postgresql-${POSTGRES_MAJOR_VERSION}-postgis-${POSTGIS_MAJOR} \
        netcat postgresql-${POSTGRES_MAJOR_VERSION}-ogr-fdw \
        postgresql-${POSTGRES_MAJOR_VERSION}-postgis-${POSTGIS_MAJOR}-scripts \
        postgresql-plpython3-${POSTGRES_MAJOR_VERSION} postgresql-${POSTGRES_MAJOR_VERSION}-pgrouting \
        postgresql-server-dev-${POSTGRES_MAJOR_VERSION} postgresql-${POSTGRES_MAJOR_VERSION}-cron

ENV PG_MAIN_VERSION 13
ENV PG_MAJOR 13

RUN \
    PG_DETAILED_VERSION="$(apt-cache madison postgresql | \
        awk -F '|' '{print $2}' | \
        tr -d ' ' | \
        grep -m1 ^${PG_MAIN_VERSION})" && \
    PG_PLPYTHON_DETAILED_VERSION="$(apt-cache madison postgresql-plpython3-${PG_MAIN_VERSION} | \
        awk -F '|' '{print $2}' | \
        tr -d ' ' | \
        grep -m1 ^${PG_MAIN_VERSION})" && \
    apt-get install -y --no-install-recommends \
       postgresql-contrib=$PG_DETAILED_VERSION  \
       postgresql-plpython3-${PG_MAIN_VERSION}=$PG_PLPYTHON_DETAILED_VERSION

RUN echo $POSTGRES_MAJOR_VERSION >/tmp/pg_version.txt

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      python-pip

RUN pip install pgxnclient
RUN pgxn install --mirror http://pgxn.dalibo.org --pg_config /usr/lib/postgresql/${PG_MAIN_VERSION}/bin/pg_config kmeans

# Compile pointcloud extension

RUN wget -O- https://github.com/pgpointcloud/pointcloud/archive/master.tar.gz | tar xz && \
cd pointcloud-master && \
./autogen.sh && ./configure && make -j 4 && make install && \
cd .. && rm -Rf pointcloud-master

# Cleanup resources
RUN apt-get -y --purge autoremove  \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Open port 5432 so linked containers can see them
EXPOSE 5432

# Copy scripts
ADD scripts /scripts
WORKDIR /scripts
RUN chmod +x *.sh

# Run any additional tasks here that are too tedious to put in
# this dockerfile directly.
RUN set -eux \
    && /scripts/setup.sh

VOLUME /var/lib/postgresql

ENTRYPOINT /scripts/docker-entrypoint.sh




















