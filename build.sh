#!/bin/bash

set -xe

docker build -t gqrx-build --progress=plain .

docker run --rm \
	--device /dev/fuse --cap-add SYS_ADMIN --security-opt apparmor:unconfined \
	-e VERSION=jlewallen \
	-v $PWD:/dist \
	gqrx-build ./appimage.sh

# Ewwww, run build as $USER?
sudo chown $USER. *.AppImage
