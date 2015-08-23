FROM phusion/passenger-full:latest
MAINTAINER Martin Fenner "mfenner@plos.org"

# Use baseimage-docker's init process
CMD ["/sbin/my_init"]

# Install bundler
RUN gem install bundler

# Enable Passenger and Nginx and remove the default site
RUN \
  rm -f /etc/service/nginx/down && \
  rm /etc/nginx/sites-enabled/default
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
COPY .env.example /home/app/lagotto/.env
RUN \
  chown -R app:app /home/app/lagotto && \
  chmod -R 755 /home/app/lagotto

# Make folders that hold data available as volumes
VOLUME ["/home/app/lagotto/tmp", "/home/app/lagotto/log"]

# Install Ruby gems via bundler, run as app user
WORKDIR /home/app/lagotto
RUN sudo -u app bundle install --path vendor/bundle

# Expose ssh, web, redis, and memcached
EXPOSE 22 80 443 6379 11211
