FROM mdillon/postgis:9.6
MAINTAINER Max Bohnet <github.com/MaxBo>

ENV PG_MAJOR 2.6

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      wget \
      postgresql-contrib postgresql-plpython-$PG_MAJOR \
      build-essential python-pip postgresql-server-dev-$PG_MAJOR \
      libssl-dev locales locales-all


RUN apt-get install -y --no-install-recommends \
      postgresql-$PG_MAJOR-pgrouting=$(apt-cache madison postgresql-$PG_MAJOR-pgrouting | awk -F'|' '{ print $2 }')

RUN pip install pgxnclient
RUN pgxn install kmeans
RUN pgxn install pg_repack


RUN mkdir -p /docker-entrypoint-initdb.d
COPY ./initdb-pgxn.sh /docker-entrypoint-initdb.d/pgxn.sh
COPY ./initdb-pgrouting.sh /docker-entrypoint-initdb.d/routing.sh
