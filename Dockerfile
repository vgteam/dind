FROM ubuntu:18.04
MAINTAINER anovak@soe.ucsc.edu

# Let's start with some basic stuff.
# Also install Docker from Ubuntu repositories, which
# should be sufficiently new to run in a container.
RUN DEBIAN_FRONTEND=noninteractive apt-get update -qq && \
    DEBIAN_FRONTEND=noninteractive apt-get install -qqy \
    apt-transport-https \
    ca-certificates \
    curl \
    lxc \
    iptables \
    sudo \
    docker.io \
    containerd && \
    apt-get clean

# Install the magic Docker startup script.
ADD ./wrapdocker /usr/local/bin/startdocker
RUN chmod +x /usr/local/bin/startdocker

# Install the magic wrapper to serve as the entry point.
ADD ./wrapdocker /usr/local/bin/wrapdocker
RUN chmod +x /usr/local/bin/wrapdocker

# Define additional metadata for our image.
VOLUME /var/lib/docker
ENTRYPOINT ["wrapdocker"]

# Make file logging the default
ENV LOG=file
