# Volumes Browser

Volumes Browser is a small script which automatically mounts every available
docker volume.

* It doesn't require root on the host.
* It mounts the volumes in read-only mode by default.
* It accepts a few parameters.
* It doesn't require any agent, or anything else than a shell and docker.
* It mounts /tmp/ in read-write mode, which allows to copy files from volumes to the host easily.

The script is based on this sh/bash one-liner:

> ```mount_command=""; for VOLUME_NAME in $(docker volume ls --format "{{.Name}}"); do mount_command="${mount_command} -v ${VOLUME_NAME}:/mnt/${VOLUME_NAME}:ro"; done; docker run ${mount_command} -v /tmp/:/tmp/ --rm -it -w /mnt/ busybox:latest sh```

## Syntax

```
Mount docker volumes and start a container.

# Syntax:

./volumes_browser.sh
	-h --help
	--mode=ro (ro for read-only, rw for read-write)
	--volumes=. (grep pattern, to filter volume names)
	--image=busybox:latest (docker image)
	--params="" (extra parameters)
	--command="sh" (command to run)
	--folder=/mnt (in which folder should volumes be mounted)

# Examples:

## Show tree structure of every volume:
./volumes_browser.sh --command=tree

## Show disk usage of every volume:
./volumes_browser.sh --image=bytesco/ncdu --command="ncdu ."

## Mount volumes in read-write mode (DANGER!):
./volumes_browser.sh --mode=rw

## Show volumes inside a web-browser:
./volumes_browser.sh --image=svenstaro/miniserve --command=/mnt --params="-p 8080:8080"
```
