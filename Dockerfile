FROM ubuntu:18.04
MAINTAINER anovak@soe.ucsc.edu

# Let's start with some basic stuff.
# Also install Docker from Ubuntu repositories, which
# should be sufficiently new to run in a container.
RUN apt-get update -qq && apt-get install -qqy \
    apt-transport-https \
    ca-certificates \
    curl \
    lxc \
    iptables \
    sudo \
    docker.io \
    containerd

# Install the magic wrapper.
ADD ./wrapdocker /usr/local/bin/wrapdocker
RUN chmod +x /usr/local/bin/wrapdocker

# Define additional metadata for our image.
VOLUME /var/lib/docker
ENTRYPOINT ["wrapdocker"]

# Make file logging the default
ENV LOG=file
