FROM kartoza/postgis:13.0
MAINTAINER Max Bohnet <github.com/MaxBo>

RUN pip install pgxnclient
RUN pgxn install --mirror http://pgxn.dalibo.org --pg_config /usr/lib/postgresql/${PG_MAIN_VERSION}/bin/pg_config kmeans




























