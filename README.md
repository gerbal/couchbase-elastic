## Couchbase with Elastic replication Dockerfile

This repository contains **Dockerfile** of [Couchbase](http://www.couchbase.com/) with Elastic replication for [Docker](https://www.docker.com/)'s [automated build](https://registry.hub.docker.com/u/clakech/couchbase-elastic/) published to the public [Docker Hub Registry](https://registry.hub.docker.com/).

### Base Docker Image

* [couchbase/server](https://hub.docker.com/r/couchbase/server/)


### Installation

1. Install [Docker](https://www.docker.com/).

2. Download [automated build](https://registry.hub.docker.com/u/clakech/couchbase-elastic/) from public [Docker Hub Registry](https://registry.hub.docker.com/): `docker pull clakech/couchbase-elastic`

   (alternatively, you can build an image from Dockerfile: `docker build -t="clakech/couchbase-elastic" github.com/clakech/couchbase-elastic`)


### Usage

   run a [elastic-couchbase](https://registry.hub.docker.com/u/clakech/couchbase-elastic/) node first:
   
   docker run -d --name elastic-couchbase -p 9200:9200 -p 9300:9300 -p 9091:9091 clakech/elastic-couchbase
   
   then, run a couchbase-elastic node linked to the elastic-couchbase node:

   docker run -d --link elastic-couchbase --name couchbase-elastic -p 8091:8091 couchbase-elastic

see [couchbase/server](https://hub.docker.com/r/couchbase/server/) for more options

After few seconds, open `http://<host>:8091` using login root/foobar to see the result.
