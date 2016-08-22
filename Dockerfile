FROM golang:1.6.2
MAINTAINER rob@robtimmer.com

# Environment variables
ENV DEBIAN_FRONTEND noninteractive

# Install dependencies
RUN apt-get update && \
    apt-get install -y git curl jq xmlstarlet && \
    rm -rf /var/lib/apt/lists/*

# Add new user
RUN useradd -m syncthing

# Install syncthing
RUN VERSION=`curl -s https://api.github.com/repos/syncthing/syncthing/releases/latest | jq -r '.tag_name'` && \
    mkdir -p /go/src/github.com/syncthing && \
    cd /go/src/github.com/syncthing && \
    git clone https://github.com/syncthing/syncthing.git && \
    cd syncthing && \
    git checkout $VERSION && \
    go run build.go && \
    mv bin/syncthing /home/syncthing/syncthing && \
    chown syncthing:syncthing /home/syncthing/syncthing && \
    rm -rf /go/src/github.com/syncthing

# Add start script and set it to the right permissions
ADD start.sh /start.sh
RUN chmod +x /start.sh

# Set the working directory
WORKDIR /home/syncthing

# Set volumes
VOLUME ["/home/syncthing/.config/syncthing", "/home/syncthing/Sync"]

# Expose required ports
EXPOSE 8384 22000 21027/udp

# Start syncthing
CMD ["/start.sh"]