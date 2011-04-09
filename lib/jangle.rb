# Loading engine only if this is not a standalone installation
unless defined? Jangle::Application
  require File.expand_path('jangle/engine', File.dirname(__FILE__))
end

require 'jangle/version'
require 'jangle/configuration'
require 'jangle/logger'
require 'jangle/liquid'
require 'jangle/mongoid'

[ 'jangle/http_auth',
  'jangle/rails_extensions',
  'jangle/controller_methods',
  'jangle/view_hooks',
  'jangle/view_methods',
  'jangle/form_builder',
  '../app/models/jangle/block',
  '../app/models/jangle/snippet',
  'jangle/cms_tag',
  'jangle/cms_tag_resource'
].each do |path|
  require File.expand_path(path, File.dirname(__FILE__))
end

Dir.glob(File.expand_path('jangle/tags/*.rb', File.dirname(__FILE__))).each do |tag_path| 
  require tag_path
end

module Jangle
  class << self

    # Modify CMS configuration
    # Example:
    #   Jangle.configure do |config|
    #     config.cms_title = 'Comfortable Mexican Sofa'
    #   end
    def configure
      yield configuration
    end
    
    # Accessor for Jangle::Configuration
    def configuration
      @configuration ||= Configuration.new
    end
    alias :config :configuration

  end
end