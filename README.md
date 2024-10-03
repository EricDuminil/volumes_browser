# Volumes Browser

[Docker documentation](https://docs.docker.com/engine/storage/) mentions that "Volumes are the best way to persist data in Docker", but it doesn't make it clear how to easily work with them.

Volumes Browser is a small script which automatically mounts every available
docker volume.

* It doesn't require root on the host.
* It mounts the volumes in read-only mode by default.
* It accepts a few parameters.
* It doesn't require any agent, or anything else than a shell and docker.
* It mounts /tmp/ in read-write mode, which allows to copy files from volumes to the host easily.

The script is based on this sh/bash one-liner:

> ```mount_command=""; for VOLUME_NAME in $(docker volume ls --format "{{.Name}}"); do mount_command="${mount_command} -v ${VOLUME_NAME}:/mnt/${VOLUME_NAME}:ro"; done; docker run ${mount_command} -v /tmp/:/tmp/ --rm -it -w /mnt/ busybox:latest sh```

It can help you find large files inside volumes, move files from one volume to another, and edit and backup config files.

## Syntax

```
./volumes_browser.sh
	-h --help
	--mode=ro (ro for read-only, rw for read-write)
	--volumes=. (grep pattern, to filter volume names)
	--image=busybox:latest (docker image)
	--params="" (extra parameters)
	--command="sh" (command to run)
	--folder=/mnt (in which folder should volumes be mounted)
```

## Examples

### Show tree structure of every volume:

`./volumes_browser.sh --command=tree`

### Show disk usage of every volume with [Ncdu](https://dev.yorhel.nl/ncdu):

`./volumes_browser.sh --image=bytesco/ncdu --command="ncdu ."`

### Look for sensitive information:

`./volumes_browser.sh --command="grep -R -o -E -n password.............. ."`

### Mount volumes in read-write mode (DANGER!):

`./volumes_browser.sh --mode=rw`

### Show volumes inside a web-browser with [miniserve](https://github.com/svenstaro/miniserve):

`./volumes_browser.sh --image=svenstaro/miniserve --command=/mnt --params="-p 8080:8080"`
