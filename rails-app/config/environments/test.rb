require "active_support/core_ext/integer/time"
Rails.application.configure do
  config.enable_reloading = false
  config.eager_load = true
  config.consider_all_requests_local = true
  config.action_controller.raise_on_missing_routes = true
  config.action_dispatch.show_exceptions = :rescuable
  config.active_record.dump_schema_after_migration = false
  config.secret_key_base = "test_secret_key_base"
end
