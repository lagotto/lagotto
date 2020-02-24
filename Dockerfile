FROM ruby:2.3-alpine

RUN apk add --no-cache \
    build-base \
    git \
    mariadb-dev \
    npm \
    && rm -rf /var/cache/apk/*
RUN npm install -g bower

RUN addgroup -g 2012 -S alm && adduser -u 2012 -G alm -S alm
RUN mkdir /code && chown alm:alm /code
WORKDIR /code
USER alm
RUN gem install bundler -v 1.17.3

# These Env vars are required to be set for Lagotto to start.
# This list should match up with the list in config/initializers/dotenv.rb
ENV \ 
    ADMIN_EMAIL=info@example.org \
    API_KEY=CHANGEME \
    CONCURRENCY=25 \
    DATABASE_URL=mysql2://username:passwork@host/database?pool=5&timeout=5000&encoding=utf8mb4 \
    MAIL_ADDRESS=localhost \
    MAIL_DOMAIN=localhost \
    MAIL_PORT=25 \
    OMNIAUTH=persona \
    RAILS_ENV=production \
    SECRET_KEY_BASE=CHANGEME \
    SERVERNAME=lagotto.local \
    SERVERS=lagotto.local \
    SITENAME="ALM Dev" \
    SKIP_EMBER=1 \ 
    SOLR_URL=http://solr-mega-dev.soma.plos.org/solr/journals_dev/select

COPY --chown=alm:alm Gemfile .
COPY --chown=alm:alm Gemfile.lock .
RUN bundle install

COPY --chown=alm:alm frontend/.bowerrc frontend/
COPY --chown=alm:alm frontend/bower.json frontend/

RUN cd frontend && bower install

RUN mkdir artifacts

COPY --chown=alm:alm . .

RUN bundle exec rake assets:precompile
CMD ["bundle", "exec", "puma"]
EXPOSE 9292