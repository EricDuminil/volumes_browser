#! /bin/sh
set -e

#################################################################################
#                        ┓┏  ┓          ┳┓                                      #
#                        ┃┃┏┓┃┓┏┏┳┓┏┓┏  ┣┫┏┓┏┓┓┏┏┏┏┓┏┓                          #
#                        ┗┛┗┛┗┗┻┛┗┗┗ ┛  ┻┛┛ ┗┛┗┻┛┛┗ ┛                           #
#################################################################################

# Volumes Browser is a small script which automatically mounts every available
# docker volume. It doesn't require root on the host, it mounts the volumes
# in read-only mode by default, and it accepts a few parameters. It doesn't
# require any agent, or anything else than a shell and docker.
#
# It mounts /tmp/ in read-write mode, which allows to copy files from volumes to
# the host easily.
#
# The script is based on this sh/bash one-liner:
#
#   mount_command=""; for VOLUME_NAME in $(docker volume ls --format "{{.Name}}"); do mount_command="${mount_command} -v ${VOLUME_NAME}:/mnt/${VOLUME_NAME}:ro"; done; docker run ${mount_command} -v /tmp/:/tmp/ --rm -it -w /mnt/ busybox:latest sh


########################
#         Help         #
########################

# Show help:
#   ./volumes_browser.sh --help
#
#       Mount docker volumes and start a container.

#       ./volumes_browser.sh
#         -h --help
#         --mode=ro (ro for read-only, rw for read-write)
#         --volumes=. (grep pattern, to filter volumes to mount)
#         --image=busybox:latest (docker image)
#         --params= (extra parameters)
#         --command=sh (command to run)
#         --folder=/mnt (in which folder should volumes be mounted)

########################
#     Normal mode      #
########################

# Mount every volume in read-only mode, and start busybox:
#   ./volumes_browser.sh
#
# You can then browse with cd, ls -l, and copy files to the host via /tmp/

########################
#    Filter volumes    #
########################

# Only mount volumes starting with "nginx":
#   ./volumes_browser.sh --volumes="^nginx"

# Only mount volumes ending with "db":
#   ./volumes_browser.sh --volumes="db$"

# Show every file inside volumes containing "config":
#   ./volumes_browser.sh --volumes=config --command=find

########################
#    Custom command    #
########################

# Display a tree structure of every volume:
#   ./volumes_browser.sh --command=tree

# Tar the content of every nginx volume:
#   ./volumes_browser.sh --volumes=nginx --command="tar cvfz /tmp/nginx.tgz -C /mnt ."

########################
#   Read-write mode    #
########################

# Mount volumes in read-write mode.
# WARNING! You are root inside the container, and could wipe out every volume easily.
# This mode can be useful in order to change permissions inside a volume, or move files
# from one volume to another. vi is available in busybox in order to edit files.
# Use with caution!
#
#   ./volumes_browser.sh --mode=rw
#
# It can be a good idea to mount only the required volumes:
#
#   ./volumes_browser.sh --mode=rw --volumes="jellyfin"

########################
#    Custom images     #
########################

# It's possible to use any image (busybox is started by default).
# You could prepare an image with a custom config, in order to edit files directly inside the container:
#   ./volumes_browser.sh --image=custom_image_with_my_vim_and_git_config --command="zsh"

# Or use existing images, e.g. to show disk usage of every volume with Ncdu:
#   ./volumes_browser.sh --image=bytesco/ncdu --command="ncdu ."

# Or to display the content of the volumes inside a web-browser:
#   ./volumes_browser.sh --image=svenstaro/miniserve --command="/mnt" --params="-p 8080:8080"

########################
#       License        #
########################

# MIT License
#
# Copyright (c) 2024 Eric Duminil
#
# https://github.com/EricDuminil/volumes_browser

################################################################################
#                              Default parameters                              #
################################################################################

MODE=ro
VOLUMES_PATTERN=.
IMAGE="busybox:latest"
COMMAND="sh"
MOUNT_FOLDER="/mnt"
EXTRA_PARAMS=""

################################################################################
#                                     Info                                     #
################################################################################

usage()
{
    echo "${green}Mount docker volumes and start a container.${no_color}"
    echo ""
    echo "${gray}# Syntax:${no_color}"
    echo ""
    echo "./volumes_browser.sh"
    echo "\t-h --help"
    echo "\t--mode=$MODE (ro for read-only, rw for read-write)"
    echo "\t--volumes=$VOLUMES_PATTERN (grep pattern, to filter volume names)"
    echo "\t--image=$IMAGE (docker image)"
    echo "\t--params=\"$EXTRA_PARAMS\" (extra parameters)"
    echo "\t--command=\"$COMMAND\" (command to run)"
    echo "\t--folder=$MOUNT_FOLDER (in which folder should volumes be mounted)"
    echo ""
    echo "${gray}# Examples:${no_color}"
    echo ""
    echo "${gray}## Show tree structure of every volume:${no_color}"
    echo "./volumes_browser.sh --command=tree"
    echo ""
    echo "${gray}## Show disk usage of every volume:${no_color}"
    echo "./volumes_browser.sh --image=bytesco/ncdu --command=\"ncdu .\""
    echo ""
    echo "${gray}## Mount volumes in read-write mode (DANGER!):${no_color}"
    echo "./volumes_browser.sh --mode=rw"
    echo ""
    echo "${gray}## Show volumes inside a web-browser:${no_color}"
    echo "./volumes_browser.sh --image=svenstaro/miniserve --command="/mnt" --params=\"-p 8080:8080\""
}

################################################################################
#                                    Colors                                    #
################################################################################

green=$(tput setaf 2)
gray=$(tput setaf 10)
orange=$(tput setaf 9)
red=$(tput setaf 1)
no_color=$(tput sgr0)

################################################################################
#                               Parse arguments                                #
################################################################################

while [ "$1" != "" ]; do
    PARAM=`echo $1 | awk -F= '{print $1}'`
    VALUE=`echo $1 | awk -F= '{print $2}'`
    case $PARAM in
        -h | --help)
            usage
            exit
            ;;
        --mode)
            MODE=$VALUE
            ;;
        --volumes)
            VOLUMES_PATTERN=$VALUE
            ;;
        --image)
            IMAGE=$VALUE
            ;;
        --command)
            COMMAND=$VALUE
            ;;
        --params)
            EXTRA_PARAMS=$VALUE
            ;;
        --folder)
            MOUNT_FOLDER=$VALUE
            ;;
        *)
            echo "ERROR: unknown parameter \"$PARAM\""
            usage
            exit 1
            ;;
    esac
    shift
done

if [ "$MODE" = "rw" ]
then
  COLOR=$red
  echo "${COLOR}WARNING! Mounting volumes in read-write mode.${no_color}";
else
  COLOR=$green
fi

################################################################################
#                      Mount volumes and start container                       #
################################################################################

mount_command=""

for VOLUME_NAME in $(docker volume ls --format "{{.Name}}" | grep ${VOLUMES_PATTERN}); do
  echo "Mount ${COLOR}${VOLUME_NAME}${no_color} to ${MOUNT_FOLDER}/${VOLUME_NAME}";
  mount_command="${mount_command} -v ${VOLUME_NAME}:${MOUNT_FOLDER}/${VOLUME_NAME}:${MODE}";
done;

echo
set -x
docker run ${mount_command} -v /tmp/:/tmp/ --rm -it -w ${MOUNT_FOLDER}/ ${EXTRA_PARAMS} ${IMAGE} ${COMMAND}

