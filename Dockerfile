ARG VERSION="6.8.38-ubi7"
FROM datastax/dse-server:${VERSION}

LABEL build_reason=use_diff_user

USER root

# Change DSE user and group UID
RUN usermod -u 10000 dse \
    && groupmod -g 999 dse

COPY --chown=dse:dse entrypoint.sh /entrypoint.sh

RUN chmod 777 /entrypoint.sh \
    && mv /opt/dse/resources/cassandra/conf /opt/dse/resources/cassandra/conf-template \
    && mv /opt/dse/resources/dse/conf /opt/dse/resources/dse/conf-template \
    && mv /opt/dse/resources/spark/conf /opt/dse/resources/spark/conf-template \
    && mv /opt/dse/resources/dse/collectd /opt/dse/resources/dse/collectd-template \
    && mv /opt/dse/bin /opt/dse/bin-template

COPY --chown=dse:dse nodesync /opt/dse/bin-template/nodesync

RUN chmod 777 /opt/dse/bin-template/nodesync

VOLUME ["/var/lib/cassandra", "/var/lib/dsefs", "/var/lib/spark", "/var/log/cassandra", "/var/log/spark", "/opt/dse/resources/cassandra/conf", "/opt/dse/resources/dse/conf", "/opt/dse/resources/dse/collectd", "/opt/dse/bin", "/opt/dse/resources/spark/conf"]

RUN (for x in   /config \
                /opt/dse \
                /opt/dse/resources/cassandra/conf \
                /opt/dse/resources/spark/conf \
                /opt/dse/resources/dse/conf \
                /opt/dse/resources/dse/collectd \
                /opt/dse/bin \
                /var/lib/cassandra \
                /var/lib/dsefs \
                /var/lib/spark \
                /var/log/cassandra \
                /var/log/spark; do \
        chown -R dse:dse $x; \
    done)

ENV DS_LICENSE=accept

USER dse
