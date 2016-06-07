FROM phusion/passenger-full:0.9.18
MAINTAINER Martin Fenner "mfenner@datacite.org"

# Set correct environment variables
ENV HOME /home/app

# Allow app user to read /etc/container_environment
RUN usermod -a -G docker_env app

# Use baseimage-docker's init process
CMD ["/sbin/my_init"]

# Update installed APT packages, clean up when done
RUN apt-get update && \
    apt-get upgrade -y -o Dpkg::Options::="--force-confold" && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Enable Passenger and Nginx and remove the default site
# Preserve env variables for nginx
RUN rm -f /etc/service/nginx/down && \
    rm /etc/nginx/sites-enabled/default
COPY vendor/docker/webapp.conf /etc/nginx/sites-enabled/webapp.conf
COPY vendor/docker/00_app_env.conf /etc/nginx/conf.d/00_app_env.conf
COPY vendor/docker/cors.conf /etc/nginx/conf.d/cors.conf

# Enable the memcached service
RUN rm -f /etc/service/memcached/down

# Prepare tmp folder for installation of Ruby gems and npm modules
RUN mkdir -p /home/app/tmp
COPY vendor /home/app/tmp/vendor
RUN chown -R app:app /home/app/tmp && \
    chmod -R 755 /home/app/tmp

# Install npm and bower packages
WORKDIR /home/app/tmp/vendor
RUN sudo -u app npm install

# Install Ruby gems
COPY Gemfile /home/app/tmp/Gemfile
COPY Gemfile.lock /home/app/tmp/Gemfile.lock
WORKDIR /home/app/tmp
RUN gem install bundler && \
    mkdir -p /home/app/tmp/vendor/bundle && \
    chown -R app:app /home/app/tmp/vendor/bundle && \
    chmod -R 755 /home/app/tmp/vendor/bundle && \
    sudo -u app bundle install --path vendor/bundle

# Copy webapp folder
ADD . /home/app/webapp
WORKDIR /home/app/webapp
RUN mkdir -p /home/app/webapp/tmp/pids && \
    chown -R app:app /home/app/webapp && \
    chmod -R 755 /home/app/webapp

# Add Runit script for sidekiq workers
RUN mkdir /etc/service/sidekiq
ADD vendor/docker/sidekiq.sh /etc/service/sidekiq/run

# Run additional scripts during container startup (i.e. not at build time)
RUN mkdir -p /etc/my_init.d
COPY vendor/docker/70_install.sh /etc/my_init.d/70_install.sh
COPY vendor/docker/80_cron.sh /etc/my_init.d/80_cron.sh
COPY vendor/docker/90_migrate.sh /etc/my_init.d/90_migrate.sh

# Expose web
EXPOSE 80
