FROM openjdk:17-jdk-buster

# Install SSH server, set root password, and clean up apt cache
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        openssh-server && \
    echo 'root:root' | chpasswd && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Configure SSH server
RUN mkdir /var/run/sshd
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

EXPOSE 22
# Start SSH server
#CMD ["/usr/sbin/sshd", "-D"]

RUN apt-get update && apt-get install -y curl dos2unix && \
 addgroup minecraft && \
 adduser --home /data --ingroup minecraft --disabled-password minecraft

COPY launch.sh /launch.sh
RUN dos2unix /launch.sh
RUN chmod +x /launch.sh

COPY bwlimit.sh /bwlimit.sh
RUN chmod +X /bwlimit.sh

VOLUME /data
WORKDIR /data
RUN chmod +x /data

EXPOSE 25565/tcp

CMD ["/usr/sbin/sshd", "-D"]

ENV MOTD "A Minecraft (FTB Presents Stoneblock 3 1.6.1) Server Powered by Docker"
ENV LEVEL world
ENV LEVELTYPE ""
ENV EULA=true
#ENV JVM_OPTS "-Xms2048m -Xmx6148m"