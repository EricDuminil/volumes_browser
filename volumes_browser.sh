#! /bin/sh
set -e


################################################################################
#                             Standard parameters                              #
################################################################################
MODE=ro
VOLUMES_PATTERN=.
IMAGE="busybox:latest"

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
        *)
            echo "ERROR: unknown parameter \"$PARAM\""
            usage
            exit 1
            ;;
    esac
    shift
done

################################################################################
#                      Mount volumes and start container                       #
################################################################################
if [ "$MODE" = "rw" ]
then
  COLOR=$red
  echo "${COLOR}WARNING! Mounting volumes in read-write mode.${no_color}";
else
  COLOR=$green
fi

mount=""

for VOLUME_NAME in $(docker volume ls --format "{{.Name}}" | grep ${VOLUMES_PATTERN}); do
  echo "Mount ${COLOR}${VOLUME_NAME}${no_color} to /mnt/${VOLUME_NAME}";
  mount="${mount} -v ${VOLUME_NAME}:/mnt/${VOLUME_NAME}:${MODE}";
done;

docker run ${mount} -v /tmp/:/tmp/ --rm -it -w /mnt/ $IMAGE sh;
