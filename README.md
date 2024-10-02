# Volumes Browser


Volumes Browser is a small script which automatically mounts every available
docker volume. It doesn't require root on the host, it mounts the volumes
in read-only mode by default, and it accepts a few parameters. It doesn't
require any agent, or anything else than a shell and docker.

It mounts /tmp/ in read-write mode, which allows to copy files from volumes to
the host easily.

The script is based on this sh/bash one-liner:

```
mount_command=""; for VOLUME_NAME in $(docker volume ls --format "{{.Name}}"); do mount_command="${mount_command} -v '${VOLUME_NAME}:/mnt/${VOLUME_NAME}:ro'"; done; docker run ${mount_command} -v /tmp/:/tmp/ --rm -it -w /mnt/ busybox:latest sh
```
