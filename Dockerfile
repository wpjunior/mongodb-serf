# Dockerizing MongoDB: Dockerfile for building MongoDB images
# Based on ubuntu:latest, installs MongoDB following the instructions from:
# http://docs.mongodb.org/manual/tutorial/install-mongodb-on-ubuntu/

FROM       ubuntu:latest
MAINTAINER Wilson Júnior <wilsonpjunior@gmail.com>

# Installation:
# Import MongoDB public GPG key AND create a MongoDB list file
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 7F0CEB10
RUN echo 'deb http://downloads-distro.mongodb.org/repo/ubuntu-upstart dist 10gen' | tee /etc/apt/sources.list.d/10gen.list

# Update apt-get sources AND install MongoDB
RUN apt-get update && apt-get install -y mongodb-org unzip wget openssh-server

# Create the MongoDB data directory
RUN mkdir -p /data/db

# install serf
RUN wget https://releases.hashicorp.com/serf/0.8.0/serf_0.8.0_linux_amd64.zip
RUN mv serf_0.8.0_linux_amd64.zip serf.zip
RUN unzip serf.zip
RUN mv serf /usr/bin/
RUN rm serf.zip

# entry points
ADD /initialize-serf.sh /usr/bin/initialize-serf.sh
ADD /initialize-ad.sh /usr/bin/initialize-ad.sh
ADD /initialize-shell.sh /usr/bin/initialize-shell.sh

ADD /mongodb-cluster-join.sh /usr/bin/mongodb-cluster-join.sh

ADD /run.sh /usr/bin/run.sh

RUN mkdir -p /etc/serf/scripts
ADD /event_handler.sh /etc/serf/scripts/event_handler.sh
ADD /mongodb_handler.sh /etc/serf/scripts/mongodb_handler.sh

# Expose port #27017 from the container to the host
EXPOSE 7946 7373
EXPOSE 27017
EXPOSE 28017

# Set /usr/bin/mongod as the dockerized entry-point application
ENTRYPOINT ["/usr/bin/run.sh"]
