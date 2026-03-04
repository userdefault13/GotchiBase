require_relative "boot"
require "rails/all"
Bundler.require(*Rails.groups)

module Gotchibase
  class Application < Rails::Application
    config.load_defaults 7.2
    config.api_only = true
    config.time_zone = "UTC"
    config.autoload_paths << Rails.root.join("app/services")
  end
end
