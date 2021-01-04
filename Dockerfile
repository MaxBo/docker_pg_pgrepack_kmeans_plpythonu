FROM kartoza/postgis:13.0
MAINTAINER Max Bohnet <github.com/MaxBo>

ENV PG_MAJOR 13
ENV PG_MAIN_VERSION 13

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      wget ca-certificates

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      python-pip

RUN pip install pgxnclient
RUN pgxn install --mirror http://pgxn.dalibo.org --pg_config /usr/lib/postgresql/${PG_MAIN_VERSION}/bin/pg_config kmeans

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
       postgresql-plpython3-${PG_MAIN_VERSION}=$PG_PLPYTHON_DETAILED_VERSION
























