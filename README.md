# deepstream-open-horizon

Deploy an NVIDIA Deepstream 5 example, using open-hotizon.

This container sets up an RTSP streaming pipeline, from your favorite RTSP input stream, through an NVIDIA Deepstream 5 pipeline, using the new Python bindings, and out to a local RTSP streaming server.

This example is setup to work with an (open-horizon)[https://github.com/open-horizon] Exchange to enable fast and easy deployment to 10,000 edge machines, or more!

This example is *big* and currently it only works on amd64 hardware with a recent NVIDIA GPU. I tested it on an NVIDIA T4.

Usage:

1. prepare the host:
   - install docker
   - install current drivers for your NVIDIA GPU card
   - configure the nvidia container runtime to be the default Docker runtime
   - install git and make
   - git clone this repo
   - cd into this repo's directory

2. Install the open-horizon Agent, and configure it for your Management Hub

3. Put your RTSPINPUT URI into your shell environment, e.g.:

export RTSPINPUT='rtsp://x.x.x.x:8554/abc'

3. If this service and pattern are already published in your Exchange, skip ahead to step 8 to register your edge machine

4. Setup to develop

docker login ...
export DOCKERHUBID=...

5 Build the container image

make build

6. Publish a service that includes this container image

make service-publish

7. Publish a software deployment pattern that includes this newly published service

make publish-pattern

8. Register your edge machine with this depooyment pattern:

make register-pattern

9. Connect to this machine to watch the RTSP output stream, using this URI:

rtsp://localhost:8554/ds-test

(or, if connecting from a different machine, reoplace "localhost" with the IP address of this machine).

