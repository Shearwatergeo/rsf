#!/bin/bash
echo "NOTE - Mounts the current working directory to /nfs/rsf."
echo "       This script should be run from the top directory."
echo ""
echo "To build the project, run:"
echo "    scl enable devtoolset-7 bash"
echo "    cd /nfs/rsf"
echo "    #. /etc/profile.d/*.sh # Does not currently do anything"
echo '    export PATH=/opt/anaconda/bin:$PATH'
echo "    ./configure --prefix=/nfs/rsf/build_docker"
echo "    make"
echo "    make install"
echo "    source /nfs/rsf/build_docker/share/madagascar/etc/env.sh
docker run --user $(id -u):$(id -g) -v $(pwd):/nfs/rsf -ti madagascar
#docker run -ti madagascar
