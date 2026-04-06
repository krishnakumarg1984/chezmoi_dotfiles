#!/usr/bin/env sh

# podman container run -v "$PWD:/workdir" -u "$(id -u):$(id -g)" --rm -it ptspts/pdfsizeopt pdfsizeopt "$@"
# podman container run -v "$PWD:/workdir" --rm -it ptspts/pdfsizeopt pdfsizeopt "$@"
podman container run -v "$PWD:/workdir" --rm -it ptspts/pdfsizeopt pdfsizeopt --use-pngout=no "$@"
