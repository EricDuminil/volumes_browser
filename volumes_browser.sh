#! /bin/sh

set -eu

MODE=ro # TODO: add to params
VOLUMES=. # TODO: add to params

green=$(tput setaf 2)
orange=$(tput setaf 9)
red=$(tput setaf 1)
no_color=$(tput sgr0)

COLOR=$green
mount=""
IMAGE="busybox:latest" # TODO: add to params

for VOLUME_NAME in $(docker volume ls --format "{{.Name}}" | grep ${VOLUMES}); do
  echo "Mount ${COLOR}${VOLUME_NAME}${no_color} to /mnt/${VOLUME_NAME}";
  mount="${mount} -v ${VOLUME_NAME}:/mnt/${VOLUME_NAME}:${MODE}";
done;

docker run ${mount} -v /tmp/:/tmp/ --rm -it -w /mnt/ $IMAGE sh;
