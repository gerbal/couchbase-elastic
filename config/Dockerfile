FROM couchbase/server

ENV ADMIN_LOGIN=root
ENV ADMIN_PASSWORD=foobar

COPY init.sh /

ENTRYPOINT ["/init.sh"]

