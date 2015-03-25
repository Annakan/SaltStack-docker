# Use phusion/baseimage as base image. To make your builds reproducible, make
# sure you lock down to a specific version, not to `latest`!
# See https://github.com/phusion/baseimage-docker/blob/master/Changelog.md for
# a list of version numbers.
FROM phusion/baseimage:latest

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]

# ...put your own build instructions here...

RUN apt-get -y upgrade
RUN apt-get -y update
RUN apt-get -y install git vim locales

ENV DEBIAN_FRONTEND noninteractive


RUN sed -i "s|exit 101|exit 0|g" /usr/sbin/policy-rc.d
# make the "en_US.UTF-8" locale
RUN apt-get update && apt-get install -y locales && rm -rf /var/lib/apt/lists/* && localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
ENV LANG en_US.utf8

RUN echo "alias ll='ls -atrhlF'" >> ~/.bashrc

# Git port is not always open lets use https
RUN git config --global url."https://".insteadOf git://
 
# Installing a master 
#RUN curl -o install_salt.sh -L https://bootstrap.saltstack.com/develop && sh install_salt.sh -M git v2014.7.0rc3
RUN curl -o install_salt.sh -L https://raw.githubusercontent.com/xclusv/salt-bootstrap/stable/bootstrap-salt.sh 

ENV PATTERN '\s+\b$CHECK_SERVICES_FUNC\b\s+\n'
ENV SUB '[  "$(runlevel)" != "unknown" ] && $CHECK_SERVICES_FUNC'
RUN sed -i.orig 's|^[ \t]*\$CHECK_SERVICES_FUNC[ \t]*|    [ \"\$\(runlevel\)\" = \"unknown\" ] \|\| \$CHECK_SERVICES_FUNC|g' install_salt.sh
RUN sh install_salt.sh -X -M git v2014.7.0rc3



# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
