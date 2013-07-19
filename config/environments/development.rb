Economy::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports and disable caching.
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = false

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations
  config.active_record.migration_error = :page_load

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = true
  
  BASE_URL = "http://localhost:3011"
  BASE_URL_DOMAIN = "localhost:3011"
  MAIL_USER_NAME = "nbarai77@gmail.com"
  MAIL_PASSWORD = "nitin777"
  MAIL_PORT = "587"
  MAIL_ADDRESS = "smtp.gmail.com"
  MAIL_DOMAIN = "gmail.com"
  LINKEDIN_CONSUMER_KEY = "fk9qc6p7z0ci"
  LINKEDIN_CONSUMER_SECRET = "neJvNNUaLjjWwC8L"  
  FACEBOOK_API = "540272539343552"
  FACEBOOK_SECRET = "aca1b41bcdb6944d8157e69055a92ca4"  
end
