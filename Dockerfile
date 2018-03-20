FROM postgres:9.6
MAINTAINER Mike Dillon <mike@appropriate.io>

ENV POSTGIS_MAJOR 2.4
ENV POSTGIS_VERSION 2.4.3+dfsg-2.pgdg80+1

RUN apt-get update \
      && apt-get install -y --no-install-recommends \
           postgresql-$PG_MAJOR-postgis-$POSTGIS_MAJOR=$POSTGIS_VERSION \
           postgresql-$PG_MAJOR-postgis-$POSTGIS_MAJOR-scripts=$POSTGIS_VERSION \
           postgis=$POSTGIS_VERSION \
      && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /docker-entrypoint-initdb.d
COPY ./initdb-postgis.sh /docker-entrypoint-initdb.d/postgis.sh
COPY ./update-postgis.sh /usr/local/bin


ENV PGROUTING_MAJOR 2.5 
ENV PGROUTING_VERSION 2.5.2-1

MAINTAINER Hans Kristian Flaatten <hans@starefossen.com> 
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      wget \
      postgresql-$PG_MAJOR-pgrouting && \
    rm -rf /var/lib/apt/lists/*
RUN mkdir -p /docker-entrypoint-initdb.d
COPY ./initdb-pgrouting.sh /docker-entrypoint-initdb.d/routing.sh

MAINTAINER Max Bohnet <github.com/MaxBo>

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      postgresql-contrib postgresql-plpython-9.6 \
      build-essential python-pip postgresql-server-dev-9.6 \
      libssl-dev locales locales-all

RUN pip install pgxnclient
RUN pgxn install kmeans
RUN pgxn install pg_repack


RUN mkdir -p /docker-entrypoint-initdb.d
COPY ./initdb-pgxn.sh /docker-entrypoint-initdb.d/pgxn.sh