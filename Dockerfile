FROM kartoza/postgis:9.6-2.4
MAINTAINER Max Bohnet <github.com/MaxBo>

ENV PG_MAJOR 9.6

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      wget ca-certificates


RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      postgresql-contrib-$PG_MAJOR  \
      postgresql-plpython-$PG_MAJOR \
      build-essential \
      python-setuptools \
      python-pip \
      python-psycopg2 \
      python-dev \
      postgresql-server-dev-all \
      libssl-dev locales locales-all


RUN apt-get install zlib1g-dev acl

RUN pip install wheel
RUN pip install pgxnclient
RUN pgxn install kmeans
RUN pgxn install pg_repack


#COPY ./initdb-pgxn.sh /docker-entrypoint-initdb.d/pgxn.sh
#COPY ./initdb-pgrouting.sh /docker-entrypoint-initdb.d/routing.sh
#RUN chmod +x /docker-entrypoint-initdb.d/*.sh