# Docker Containers For Compiling and Running

The files in this directory can be used to create a Docker container that effectively acts as a VM on your machine.
To build the image run:
```
./build_image.sh
```
 If the images compile successfully, then you should see two new images in `docker image list`: madagascar, and madagascar-x11.

The madagascar image is a relatively basic container that contains all of the dependencies for compiling the code. Unfortunately, it is not very practical because it does not have an X11 server, and the compiled executables cannot be used outside of Docker without installing many of the system libraries required to compile the code. Therefore, `dockerfile` in this directory can be viewed as a set of instructions for configuring a machine to compile the code, but is not of much further use alone.

The madagascar-x11 extends the image with some Docker magic that allows the spawned container to act as a VM. To use it, launch `start_x11_server.sh` from the top directory of the code. I typically run
```
pushd .. && docker/start_x11_server.sh; popd
```
from the docker directory so that I can quickly rebuild the image as needed. Once the container is launched, you will see a bunch of messages related to services starting, but will not be able to interact with the terminal anymore. This is the server that is now running. To continue, start a new terminal or use `ctrl+p, ctrl+q` to leave the container.

Running `docker container list` should show a container named as `madagascar-$USER`. Currently, this is mapped to port 2222 so only one user/container can run on a machine. This can be extended by changing the port number. To log in, run:
```
ssh -v -X -p 2222 -o "UserKnownHostsFile /dev/null" -oStrictHostKeyChecking=no <user>@localhost
```
The password is currently equal to the username.
The -o arguments are used to ensure that the RSA keys are not added to ~/.ssh/known_hosts because they change every time a new container is launched.

Once inside the container, the top directory of your madagascar repository will be mounted to /nfs/rsf. To compile:
```
cd /nfs/rsf
scl enable devtoolset-7 bash
./configure --prefix=/nfs/rsf/build_docker
make
make install
source /nfs/rsf/build_docker/share/madagascar/etc/env.sh
```
Then, the project should be ready for use.

Note that to recreate/kill the docker container you should first run:
```
docker container rm madagascar-$USER -f
```