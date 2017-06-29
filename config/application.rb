require_relative 'boot'

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_view/railtie"
#require "action_cable/engine"
require "sprockets/railtie"
# require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Reki
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
    #

    # I18n setting
    I18n.enforce_available_locales = true
    I18n.available_locales = [:ja, :en]
    config.i18n.load_path += Dir[config.root.join("config", 'locales', "**", '*.yml').to_s]
    config.i18n.default_locale = :ja

    # Timezone
    config.time_zone = 'Tokyo'
    config.active_record.default_timezone = :local

    # Json
    config.active_support.escape_html_entities_in_json = false

    # Job
    config.active_job.queue_adapter = :delayed_job

    # Auto Load path
    config.autoload_paths << config.root.join("app", "apis")
    config.autoload_paths << config.root.join("app", "validators")
    config.autoload_paths << config.root.join("lib")

    # generator
    config.generators do |g|
      g.javascripts false
      g.stylesheets false
      g.helper false
      g.jbuilder false
      g.test_framework :rspec,
        view_specs: false,
        request_specs: false,
        routing_specs: false,
        fixture: false
      g.integration_tool :rspec
      g.fixture_replacement :factory_girl, dir: 'spec/factories'
    end

    Mime::Type.register "image/png", :png

    config.after_initialize do
      Rails.application.routes.default_url_options[:host] = Settings.application.host
    end
  end
end
