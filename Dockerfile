FROM kartoza/postgis:10.0-2.4
MAINTAINER Max Bohnet <github.com/MaxBo>

ENV PG_MAIN_VERSION 10
ENV PG_MAJOR 10.0

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      wget ca-certificates


RUN apt-get update && \
    PG_DETAILED_VERSION="$(apt-cache madison postgresql | \
        awk -F '|' '{print $2}' | \
        tr -d ' ' | \
        grep -m1 ^${PG_MAIN_VERSION})" && \
    PG_PLPYTHON_DETAILED_VERSION="$(apt-cache madison postgresql-plpython-${PG_MAIN_VERSION} | \
        awk -F '|' '{print $2}' | \
        tr -d ' ' | \
        grep -m1 ^${PG_MAIN_VERSION})" && \
    apt-get install -y --no-install-recommends \
      postgresql-contrib=$PG_DETAILED_VERSION  \
      postgresql-plpython-${PG_MAIN_VERSION}=$PG_PLPYTHON_DETAILED_VERSION \
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
RUN pgxn install --pg_config /usr/lib/postgresql/${PG_MAIN_VERSION}/bin/pg_config kmeans
RUN pgxn install --pg_config /usr/lib/postgresql/${PG_MAIN_VERSION}/bin/pg_config pg_repack

ADD start-postgresql.sh /
ADD initdb-pgxn.sh /
ADD initdb-pgrouting.sh /
ADD optimize-kernel.sh /
ADD setup-ssl-certificates.sh /

RUN chmod +x /*.sh

ENTRYPOINT /start-postgresql.sh
