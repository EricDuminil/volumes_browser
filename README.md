# Volumes Browser

[Docker documentation](https://docs.docker.com/engine/storage/) mentions that "Volumes are the best way to persist data in Docker", but it doesn't make it clear how to easily work with them.

Volumes Browser is a small script which automatically mounts every available docker volume.

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

### Most basic

`./volumes_browser.sh`

>     Mount joplin-data to /mnt/joplin-data
>     Mount ollama_ollama to /mnt/ollama_ollama
>     Mount uptime-kuma to /mnt/uptime-kuma
>     Mount vaultwarden-data to /mnt/vaultwarden-data
>     
>     + docker run -v joplin-data:/mnt/joplin-data:ro -v ollama_ollama:/mnt/ollama_ollama:ro -v uptime-kuma:/mnt/uptime-kuma:ro -v vaultwarden-data:/mnt/vaultwarden-data:ro -v /tmp/:/tmp/ --rm -it -w /mnt/ busybox:latest sh
>     
>     /mnt # ls -l
>     total 28
>     drwxr-xr-x    5 1000     1000          4096 Oct  1 15:42 joplin-data
>     drwxr-xr-x    3 root     root          4096 Aug 23 10:25 ollama_ollama
>     drwxr-xr-x    5 root     root          4096 Sep 24 16:36 uptime-kuma
>     drwxr-xr-x    6 root     root          4096 Sep 21 07:34 vaultwarden-data
>     /mnt #

You can then browse the volumes with `cd`, `ls -l`, `cat`, and copy files to the host via `/tmp/`.

### Show tree structure of every volume:

`./volumes_browser.sh --command=tree`

>     .
>     ├── joplin-data
>     │   ├── cache
>     │   ├── database.sqlite
>     │   ├── keymap.json
>     │   ├── log.txt
>     │   ├── resources
>     │   │   ├── 0592d3c59f36410b844a95cb9e1ba453.pdf
>     │   │   ├── 0be515ddd0a14ccba946fbe16532d0b8.pdf
>     ...


### Show disk usage of every volume with [Ncdu](https://dev.yorhel.nl/ncdu):

`./volumes_browser.sh --image=bytesco/ncdu --command="ncdu ."`

>     ncdu 1.20 ~ Use the arrow keys to navigate, press ? for help
>     --- /mnt ---------------------------------------------------
>         4.3 GiB [#####################] /ollama_ollama
>       228.9 MiB [#                    ] /ollama_open-webui
>        28.1 MiB [                     ] /joplin-data
>        22.4 MiB [                     ] /uptime-kuma
>         4.0 MiB [                     ] /vaultwarden-data
>       264.0 KiB [                     ] /nginx_certbot_conf
>         4.0 KiB [                     ] /nginx_geoipupdate_data

### Look for sensitive information:

`./volumes_browser.sh --command="grep -R -o -E -n password.............. ."`

### Mount volumes in read-write mode (DANGER!):

`./volumes_browser.sh --mode=rw`

### Show volumes inside a web-browser with [miniserve](https://github.com/svenstaro/miniserve):

`./volumes_browser.sh --image=svenstaro/miniserve --command=/mnt --params="-p 8080:8080"`
