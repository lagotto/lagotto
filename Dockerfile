FROM ruby:2.2-alpine

RUN apk add --no-cache \
    build-base \
    git \
    mariadb-dev \
    nodejs \
    && rm -rf /var/cache/apk/*
RUN npm install -g bower

RUN addgroup -g 2012 -S alm && adduser -u 2012 -G alm -S alm
RUN mkdir /code && chown alm:alm /code
WORKDIR /code
USER alm
RUN gem install bundler -v 1.17.3

ENV \ 
    ADMIN_EMAIL=info@example.org \
    API_KEY=CHANGEME \
    APPLICATION=lagotto \
    AWS_KEY= \
    AWS_KEYNAME= \
    AWS_KEYPATH= \
    AWS_SECRET= \
    CAS_INFO_URL= \
    CAS_PREFIX= \
    CAS_URL= \
    CONCURRENCY=25 \
    CREATOR="Public Library of Science" \
    DATABASE_URL=mysql2://username:passwork@host/database?pool=5&timeout=5000&encoding=utf8mb4 \
    DO_PROVIDER_TOKEN= \
    DO_SIZE=1GB \
    GITHUB_CLIENT_ID= \
    GITHUB_CLIENT_SECRET= \
    GITHUB_URL=https://github.com/lagotto/lagotto \
    HOSTNAME=lagotto.local \
    IMPORT= \
    LOG_LEVEL=info \
    MAIL_ADDRESS=localhost \
    MAIL_DOMAIN=localhost \
    MAIL_PORT=25 \
    OMNIAUTH=persona \
    ORCID_CLIENT_ID= \
    ORCID_CLIENT_SECRET= \
    RAILS_ENV=production \
    RAILS_LOG_TO_STDOUT=true \
    SECRET_KEY_BASE=CHANGEME \
    SERVERNAME=lagotto.local \
    SERVERS=lagotto.local \
    SITENAME="ALM Dev" \
    SITENAMELONG="PLOS ALM" \
    SKIP_EMBER=1 \
    SOLR_URL= \
    ZENODO_KEY= \
    ZENODO_URL=https://sandbox.zenodo.org/api/

COPY --chown=alm:alm Gemfile .
COPY --chown=alm:alm Gemfile.lock .
RUN bundle install

COPY --chown=alm:alm frontend/.bowerrc frontend/
COPY --chown=alm:alm frontend/bower.json frontend/

RUN cd frontend && bower install

COPY --chown=alm:alm . .

RUN bundle exec rake assets:precompile
CMD ["bundle", "exec", "puma"]
EXPOSE 9292