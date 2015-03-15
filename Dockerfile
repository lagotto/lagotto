FROM phusion/passenger-full:latest
MAINTAINER Martin Fenner "mfenner@plos.org"

# Set correct environment variables
ENV HOME /root

# Use baseimage-docker's init process
CMD ["/sbin/my_init"]

# Enable Passenger and Nginx and remove the default site
RUN rm -f /etc/service/nginx/down
RUN rm /etc/nginx/sites-enabled/default
COPY vendor/docker/lagotto.conf /etc/nginx/sites-enabled/lagotto.conf
COPY vendor/docker/00_app_env.conf /etc/nginx/conf.d/00_app_env.conf

# Enable the Redis service.
RUN rm -f /etc/service/redis/down

# Enable the Memcached service.
RUN rm -f /etc/service/memcached/down

# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Prepare app folder
RUN mkdir /home/app/lagotto
ADD . /home/app/lagotto

# Make folders that hold data available as volumes
VOLUME ["/home/app/lagotto/tmp", "/home/app/lagotto/log", "/home/app/lagotto/data"]]

EXPOSE 80 443
