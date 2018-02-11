#
# FPM Dockerfile
#
# https://github.com/dockerfile/fpm
#

# Pull base image.
FROM ruby

# Install FPM.
RUN gem install fpm
RUN apt-get update && apt-get install -y rpm zip && apt-get clean && rm -rf /var/lib/apt/lists/*

# Define working directory.
WORKDIR /data

# Define default command.
CMD ["bash"]