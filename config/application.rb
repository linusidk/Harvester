require File.expand_path('../boot', __FILE__)

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_view/railtie"
require "sprockets/railtie"
require "rails/test_unit/railtie"
require 'mongoid'
load "app/manage_crawl/gen_crawlers.rb"
load "app/api/api_calls.rb"
load "config/initializers/project_config.rb"
load "config/initializers/docmanager.rb"

Mongoid.load!(File.expand_path('mongoid.yml', './config'))
# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module DocumentLoader
  class Application < Rails::Application
    include ApiCalls
    include GenCrawlers
#    sleep(90)
    config.action_controller.permit_all_parameters = true
    config.active_job.queue_adapter = :resque
    gen_all_crawlers
  end
end
