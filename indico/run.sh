#!/bin/bash

docker run --rm -d \
-p 4080:80 -p 4443:443 \
-v /mnt/docker/data/indico/etc:/opt/indico/etc \
-v /mnt/docker/data/indico/ssl:/opt/indico/ssl:ro \
-v /mnt/docker/data/indico/db:/opt/indico/db \
-v /mnt/docker/data/indico/archive:/opt/indico/archive \
indico
