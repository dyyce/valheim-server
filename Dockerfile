FROM didstopia/base:nodejs-12-steamcmd-ubuntu-18.04

LABEL maintainer="Didstopia <support@didstopia.com>"

# Fixes apt-get warnings
ARG DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt-get update && \
	apt-get install -y --no-install-recommends \
    libsdl2-2.0-0:i386 && \
    rm -rf /var/lib/apt/lists/*

# Set the default working directory
WORKDIR /

# Create the volume directories
RUN mkdir -p /steamcmd/valheim /app/.config/unity3d/IronGate/Valheim

# Setup scheduling support
ADD scheduler_app/ /app/scheduler_app/
WORKDIR /app/scheduler_app
RUN npm install

# Add the steamcmd installation script
ADD install.txt /app/install.txt

# Copy scripts
ADD start.sh /app/start.sh
ADD update_check.sh /app/update_check.sh
RUN chmod +x /app/*.sh

# Fix permissions
RUN chown -R 1000:1000 \
    /steamcmd \
    /app

# Run as a non-root user by default
ENV PGID 1000
ENV PUID 1000

# Expose necessary ports
EXPOSE 2456/tcp
EXPOSE 2456/udp
EXPOSE 2457/udp
EXPOSE 2457/udp
EXPOSE 2458/udp
EXPOSE 2458/udp

# Setup default environment variables for the server
ENV VALHEIM_SERVER_STARTUP_ARGUMENTS "-quit -batchmode -nographics -dedicated"
ENV VALHEIM_SERVER_NAME "Docker"
ENV VALHEIM_SERVER_WORLD "Dedicated"
ENV VALHEIM_SERVER_PORT "2456"
ENV VALHEIM_SERVER_PUBLIC "1"
ENV VALHEIM_SERVER_PASSWORD ""
ENV VALHEIM_SERVER_ADMINS ""
ENV VALHEIM_BRANCH "public"
ENV VALHEIM_START_MODE "0"
ENV VALHEIM_UPDATE_CHECKING "0"

# Define directories to take ownership of
ENV CHOWN_DIRS "/app,/steamcmd"

# Expose the volumes
VOLUME [ "/steamcmd/valheim", "/app/.config/unity3d/IronGate/Valheim" ]

# Start the server
CMD [ "bash", "/app/start.sh" ]
