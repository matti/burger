FROM alpine:3.10

RUN apk add --no-cache \
  bash curl \
  ca-certificates openssl \
  ruby ruby-irb ruby-json ruby-etc

WORKDIR /app

COPY app/Gemfile* ./

RUN apk --no-cache add --virtual .build-dependencies \
  ruby-dev build-base \
  && gem install bundler -v 2.1.4 --no-ri --no-rdoc \
  && bundle install \
  && apk del .build-dependencies

COPY app .

ENTRYPOINT ["/app/entrypoint.sh"]
