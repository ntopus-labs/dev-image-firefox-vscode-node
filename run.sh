#! /bin/bash
XSOCK=/tmp/.X11-unix
XAUTH=/tmp/.docker.xauth
touch $XAUTH
xauth nlist $DISPLAY | sed -e 's/^..../ffff/' | xauth -f $XAUTH nmerge -

docker run --group-add audio \
  -v $XSOCK:$XSOCK:rw \
  -v $XAUTH:$XAUTH:rw \
  --device=/dev/dri/card0:/dev/dri/card0 \
  --device /dev/snd \
  -e DISPLAY=$DISPLAY \
  -e XAUTHORITY=$XAUTH \
  -u node \
  --net=host \
  -p=$PORT:$PORT \
  -v $PWD:/home/node/project \
  --rm -it --entrypoint /bin/bash \
  ntopus/dev-image-firefox-vscode-node:lts -c "/usr/bin/code -w /home/node/project"