#!/usr/bin/env sh

# docker container run -v "$PWD:/workdir" -u "$(id -u):$(id -g)" --rm -it ptspts/pdfsizeopt pdfsizeopt "$@"
docker container run -v "$PWD:/workdir" --rm -it ptspts/pdfsizeopt pdfsizeopt --use-pngout=no "$@"
