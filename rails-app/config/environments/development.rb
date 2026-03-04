require "active_support/core_ext/integer/time"
Rails.application.configure do
  config.enable_reloading = true
  config.eager_load = false
  config.consider_all_requests_local = true
  config.active_record.migration_error = :page_load
  config.active_record.verbose_query_logs = true
  config.secret_key_base = ENV.fetch("SECRET_KEY_BASE", "dev_secret_key_base_32_chars_min")
end
