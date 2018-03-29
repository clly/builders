#
# FPM Dockerfile
#
# https://github.com/dockerfile/fpm
#

# Pull base image.
FROM ruby

# Install FPM.
RUN gem install fpm
RUN apt-get update && apt-get upgrade -y && apt-get install -y rpm zip \ 
    createrepo build-essential python-dev python-six python-virtualenv \
    libcurl4-nss-dev libsasl2-dev libsasl2-modules maven libapr1-dev libsvn-dev \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Define working directory.
WORKDIR /data

# Define default command.
CMD ["bash"]
