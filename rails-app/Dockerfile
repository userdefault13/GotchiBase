FROM ruby:3.2-slim
WORKDIR /app
RUN apt-get update -qq && apt-get install -y --no-install-recommends build-essential libpq-dev libyaml-dev && rm -rf /var/lib/apt/lists/*
COPY Gemfile* ./
RUN bundle install
COPY . .
EXPOSE 3000
CMD ["sh", "-c", "bundle exec rails db:create db:migrate db:seed && bundle exec rails s -b 0.0.0.0"]
