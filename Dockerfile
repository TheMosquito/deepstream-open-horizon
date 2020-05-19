FROM nvcr.io/nvidia/deepstream:5.0-dp-20.04-triton

# Install dependencies
RUN apt-get update --fix-missing && apt-get install -y \
   ca-certificates \
   build-essential \
   autoconf libtool \
   python3 \
   python3-dev \
   python3-pip \
   python3-setuptools \
   python-gi-dev \
   libgstreamer1.0-dev \
   python3-opencv \
   libgstrtspserver-1.0-0 \
   gstreamer1.0-rtsp \
   libgirepository1.0-dev \
   gobject-introspection \
   gir1.2-gst-rtsp-server-1.0 \
   && apt-get clean && rm -rf /var/lib/apt/lists/*

# Copy the Python deepstrem bindings. These were downloaded from here:
#   https://developer.nvidia.com/deepstream_python_v0.5
COPY deepstream_python_v0.9.tbz2 /
WORKDIR /
RUN tar -xvf /deepstream_python_v0.9.tbz2
RUN tar -xvf /deepstream_python_v0.9/ds_pybind_v0.9.tbz2 -C /opt/nvidia/deepstream/deepstream-5.0/sources

# Copy the python source and config file
COPY deepstream-rtsp.py deepstream-rtsp.cfg / 

# Set the WORKDIR and default ENTRYPOINT command
# Unfortunately the base container sets an ENTRYPOINT, not a CMD, so it is a
# very awkward to use this container except as a shell command.
# To do development, uncomment the 2 lines below, and comment the other two.
#WORKDIR /outside
#ENTRYPOINT /bin/bash
WORKDIR /
ENTRYPOINT python3 ./deepstream-rtsp.py

