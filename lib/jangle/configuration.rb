module Jangle
  class Configuration

    # Don't like Comfortable Mexican Sofa? Set it to whatever you like. :(
    attr_accessor :cms_title

    # Module that will handle authentication to access cms-admin area
    attr_accessor :authentication

    # Location of YAML files that can be used to render pages instead of pulling
    # data from the database. Not active if not specified.
    attr_accessor :seed_data_path

    # Default url to access admin area is http://yourhost/cms-admin/ 
    # You can change 'cms-admin' to 'admin', for example.
    attr_accessor :admin_route_prefix

    # /cms-admin redirects to /cms-admin/pages but you can change it
    # to something else
    attr_accessor :admin_route_redirect

    # Let CMS handle site creation and management. Enabled by default.
    attr_accessor :auto_manage_sites

    # Not allowing irb code to be run inside page content. True by default.
    attr_accessor :disable_irb

    # Caching for css/js. For admin layout and ones for cms content. Enabled by default.
    attr_accessor :enable_caching

    # Upload settings
    attr_accessor :upload_file_options

    # Override the hostname when looking up which site to use
    attr_accessor :override_host

    attr_accessor :cms_css_path
    attr_accessor :cms_js_path
    attr_accessor :widget_css_path
    attr_accessor :widget_js_path

    attr_accessor :enable_logs
    
    # Configuration defaults
    def initialize
      @cms_title            = 'Jangle MicroCMS'
      @authentication       = 'Jangle::HttpAuth'
      @seed_data_path       = nil
      @admin_route_prefix   = 'jangle'
      @admin_route_redirect = "/#{@admin_route_prefix}/pages"
      @auto_manage_sites    = true
      @disable_irb          = true
      @enable_caching       = true
      @upload_file_options  = {}
      @override_host        = nil
      @cms_css_path         = '/stylesheets/layouts'
      @cms_js_path          = '/javascripts/layouts'
      @widget_css_path      = '/stylesheets/widgets'
      @widget_js_path       = '/javascripts/widgets'
      @enable_logs          = true
    end

  end
end