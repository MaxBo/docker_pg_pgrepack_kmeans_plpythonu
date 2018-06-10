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
RUN pgxn install --pg_config /usr/lib/postgresql/$PG_MAJOR/bin/pg_config kmeans
RUN pgxn install --pg_config /usr/lib/postgresql/$PG_MAJOR/bin/pg_config pg_repack

ADD start-postgresql.sh /
ADD initdb-pgxn.sh /
ADD initdb-pgrouting.sh /
ADD optimize-kernel.sh /
ADD setup-ssl-certificates.sh /

RUN chmod +x /*.sh

ENTRYPOINT /start-postgresql.sh
