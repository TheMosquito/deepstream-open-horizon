# deepstream-open-horizon

Deploy an NVIDIA Deepstream 5 example, using open-hotizon.

This container sets up an RTSP streaming pipeline, from your favorite RTSP input stream, through an NVIDIA Deepstream 5 pipeline, using the new Python bindings, and out to a local RTSP streaming server.

This example is setup to work with an (open-horizon)[https://github.com/open-horizon] Exchange to enable fast and easy deployment to 10,000 edge machines, or more!

This example requires NVIDIA hardware. The container is *big* and takes quite a while to build on small machines like the nano. Currently this example works only on:
 - amd64 hardware with a recent NVIDIA GPU. I tested it on an NVIDIA T4, and
 - NVIDIA Jetson (arm64) hardware. I tested it on an NVIDIA nano.

### Usage:

1. prepare the host:
   - install docker
   - install current software for your NVIDIA GPU (e.g., CUDA and on Jetsons, JetPack)
   - configure the nvidia container runtime to be the default Docker runtime
   - install git, make, curl and jq (useful tools for development)
   - git clone this repo
   - cd into this repo's directory

2. Install the open-horizon Agent, and configure it for your Management Hub

3. Put your RTSP input URI into your shell environment, e.g.:

```
export RTSPINPUT='rtsp://x.x.x.x:8554/abc'
```

4. If this service and pattern are already published in your Exchange, skip ahead to step 9 to register your edge machine, otherwise follow these steps to publish it:

5. Setup your machiine for open-horizon development

```
docker login ...
export DOCKERHUBID=...
hzn key create <YOUR-COMANY> <YOUR-EMAIL>
```

6. Download the Deepstream Python bindings (I cannot include them here -- login required for download). Use the ZURL below and download it into this directory:

https://developer.nvidia.com/deepstream_python_v0.5

7. Build the container, and optionally test it

```
make build
make dev
# ... watch the output as it runs
# ... wait for the "Deepstream RTSP pipeline example is starting" message, then
# ... connect to the RTSP output stream to verify it works
Ctrl-C  # To stop it when you are finished
```

8. Publish the container as an open-horizon service and publish an open-horizon software deployment pattern that includes this service

```
make service-publish
make publish-pattern
```

9. Register your edge machine with this deployment pattern:

```
make register-pattern
```

10. Wait a moment (30 seconds?) for the output streamer to start up, then connect to this edge machine using its "**IPADDRESS**" and watch the RTSP output stream, using this URI:

rtsp://**IPADDRESS**:8554/ds

(or, if connecting from the same machine, you can just use "localhost" instead of "**IPADDRESS**").

### Advanced:

Once you have verified things with the above, take a look at the source code
and make changes to replace the inferencing engine with one of your own, or
to change the input source type (e.g., a file instead of an RTSP stream) or
to change the output (e.g., direct it to a screen window instead of the RTSP
stream output used here).


