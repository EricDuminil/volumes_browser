#! /bin/sh
set -e

# ./volumes_browser.sh
# ./volumes_browser.sh --mode=rw
# ./volumes_browser.sh --command=tree
# ./volumes_browser.sh --image=bytesco/ncdu --command="ncdu ." 

################################################################################
#                             Standard parameters                              #
################################################################################
MODE=ro
VOLUMES_PATTERN=.
IMAGE="busybox:latest"
COMMAND="sh"
MOUNT_FOLDER="/mnt"
PARAMS=""

################################################################################
#                                     Info                                     #
################################################################################

usage()
{
    echo "Mount docker volumes."
    echo ""
    echo "./volumes_browser.sh"
    echo "\t-h --help"
    echo "\t--mode=$MODE (ro for read-only, rw for read-write)"
    echo "\t--volumes=$VOLUMES_PATTERN (grep pattern, to filter volumes to mount)"
    echo "\t--image=$IMAGE (docker image)"
    echo "\t--params=$PARAMS (extra parameters)"
    echo "\t--command=$COMMAND (command to run)"
    echo "\t--folder=$MOUNT_FOLDER (in which folder should volumes be mounted)"
    echo ""
}

################################################################################
#                                    Colors                                    #
################################################################################
green=$(tput setaf 2)
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
            PARAMS=$VALUE
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

mount=""

for VOLUME_NAME in $(docker volume ls --format "{{.Name}}" | grep ${VOLUMES_PATTERN}); do
  echo "Mount ${COLOR}${VOLUME_NAME}${no_color} to /${MOUNT_FOLDER}/${VOLUME_NAME}";
  mount="${mount} -v ${VOLUME_NAME}:/${MOUNT_FOLDER}/${VOLUME_NAME}:${MODE}";
done;

echo
set -x
docker run ${mount} -v /tmp/:/tmp/ --rm -it -w /${MOUNT_FOLDER}/ ${PARAMS} ${IMAGE} ${COMMAND};
