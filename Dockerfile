FROM phusion/passenger-full:latest
MAINTAINER Martin Fenner "mfenner@plos.org"

# Set correct environment variables.
ENV HOME /root

# Use baseimage-docker's init process.
CMD ["/sbin/my_init"]

# Enable Passenger and Nginx and remove the default site
RUN rm -f /etc/service/nginx/down
RUN rm /etc/nginx/sites-enabled/default
ADD vendor/docker/nginx.conf /etc/nginx/main.d/nginx.conf
ADD vendor/docker/lagotto.conf /etc/nginx/sites-enabled/lagotto.conf

# Prepare app folder
RUN mkdir /home/app/lagotto
ADD . /home/app/lagotto

# Enable the Redis service.
RUN rm -f /etc/service/redis/down

# Enable the memcached service.
RUN rm -f /etc/service/memcached/down

# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
