# Phase 4: Replace with full Sinatra setup
FROM ruby:3.2-alpine
WORKDIR /app
RUN apk add --no-cache build-base postgresql-dev
COPY Gemfile* ./
RUN bundle install
COPY . .
CMD ["bundle", "exec", "ruby", "app.rb"]
