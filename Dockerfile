FROM kartoza/postgis:13.0
MAINTAINER Max Bohnet <github.com/MaxBo>

ENV PG_MAIN_VERSION 13
ENV PG_MAJOR 13

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      wget ca-certificates


RUN apt-get update && \
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
      postgresql-plpython3-${PG_MAIN_VERSION}=$PG_PLPYTHON_DETAILED_VERSION \
      build-essential \
      python-setuptools \
      python-pip \
      python-psycopg2 \
      python-dev \
      postgresql-server-dev-all \
      libssl-dev locales locales-all


RUN apt-get install -y zlib1g-dev acl

RUN pip install wheel
RUN pip install pgxnclient
RUN pgxn install --mirror http://pgxn.dalibo.org --pg_config /usr/lib/postgresql/${PG_MAIN_VERSION}/bin/pg_config kmeans
#RUN pgxn install --pg_config /usr/lib/postgresql/${PG_MAIN_VERSION}/bin/pg_config pg_repack

ADD start-postgresql.sh /scripts/
#ADD initdb-pgxn.sh /
#ADD initdb-pgrouting.sh /
#ADD optimize-kernel.sh /
ADD setup-ssl-certificates.sh /scripts/

RUN chmod +x /scripts/*.sh
#RUN chown postgres:postgres ./*.sh
#USER postgres:postgres

ENV DEFAULT_ENCODING "UTF8"
ENV DEFAULT_COLLATION "de_DE.UTF-8"
ENV DEFAULT_CTYPE "de_DE.UTF-8"
ENV POSTGRES_USER postgres
ENV POSTGRES_PASS secret
ENV POSTGRES_DB=postgis_template

ENTRYPOINT ./start-postgresql.sh
#ENTRYPOINT ./docker-entrypoint.sh

#USER postgres:postgres
