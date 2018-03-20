FROM starefossen/pgrouting:9.6-2.3-2.3
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