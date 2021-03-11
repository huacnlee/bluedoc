FROM bluedoc/base:2.7.2-alpine

ENV RAILS_ENV "production"
ENV DATABASE_URL "postgres://postgres@localhost:5432/bluedoc"
ENV REDIS_URL "redis://localhost:6379/1"
ENV APP_HOST "http://localhost"

EXPOSE 443 80

WORKDIR /home/app/bluedoc

RUN mkdir -p /home/app &&\
  find / -type f -iname '*.apk-new' -delete &&\
  rm -rf '/var/cache/apk/*' '/tmp/*'

ADD Gemfile Gemfile.lock package.json yarn.lock /home/app/bluedoc/
RUN bundle config mirror.https://rubygems.org https://gems.ruby-china.com
RUN bundle install --deployment --jobs 20 --retry 5 &&\
  yarn &&\
  find /home/app/bluedoc/vendor/bundle -name tmp -type d -exec rm -rf {} + && \
  rm -Rf /home/app/bluedoc/vendor/bundle/ruby/*/cache
ADD . /home/app/bluedoc
ENV RUBYOPT "--jit"
ARG COMMIT_VERSION
ENV BLUEDOC_BUILD_VERSION=${COMMIT_VERSION}

VOLUME /home/app/bluedoc/storage \
  /home/app/bluedoc/log \
  /home/app/bluedoc/tmp \
  /home/app/bluedoc/data \
  /tmp \
  /var/lib/postgresql \
  /var/lib/redis \
  /usr/share/elasticsearch/data

RUN bundle exec rails assets:precompile RAILS_ENV=production SECRET_KEY_BASE=fake_secure_for_compile

RUN rm -Rf /home/app/bluedoc/.git && \
  rm -Rf /home/app/bluedoc/app/javascript && \
  rm -Rf /home/app/bluedoc/docs && \
  rm -Rf /home/app/bluedoc/node_modules && \
  rm -Rf /home/app/bluedoc/package.json && \
  rm -Rf /home/app/bluedoc/yarn.lock && \
  rm -Rf /home/app/bluedoc/.babelrc && \
  rm -Rf /home/app/bluedoc/.circleci && \
  rm -Rf /home/app/bluedoc/.rubocop.yml && \
  rm -Rf /home/app/bluedoc/.dockerignore && \
  rm -Rf /home/app/bluedoc/.ruby-version && \
  rm -Rf /home/app/bluedoc/.byebug_history && \
  rm -Rf /home/app/bluedoc/test && \
  rm -Rf /usr/local/share/.cache && \
  rm -Rf /home/app/bluedoc/vendor/cache

# Add config
ADD ./config/elasticsearch /usr/share/elasticsearch/config
ADD ./config/etc/redis.conf /etc/redis.conf
ADD ./config/nginx/ /etc/nginx
ADD ./config/etc/Caddyfile /etc/Caddyfile

RUN apk del .builddeps

ENTRYPOINT ["/home/app/bluedoc/bin/docker-entrypoint"]
CMD ["/home/app/bluedoc/bin/docker-start"]
