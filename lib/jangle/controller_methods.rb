module Jangle::ControllerMethods
  
  def self.included(base)
    
    # If application controller doesn't have template associated with it
    # CMS will attempt to find one. This is so you don't have to explicitly
    # call render :jangle_page => '/something'
    base.rescue_from 'ActionView::MissingTemplate' do |e|
      begin
        render :jangle_page => request.path
      rescue ActionView::MissingTemplate
        raise e
      end
    end
    
    # Now you can render jangle_page simply by calling:
    #   render :jangle_page => '/path/to/page'
    # This way application controllers can use CMS content while populating
    # instance variables that can be used in partials (that are included by
    # by the cms page and/or layout)
    def render(options = {}, locals = {}, &block)
      if options.is_a?(Hash) && path = options.delete(:jangle_page)
        site = Jangle::Site.find_by_hostname(request.host.downcase)
        page = Jangle::Page.load_from_file(site, path) if site && Jangle.configuration.seed_data_path
        page ||= site && site.jangle_pages.find_by_full_path(path)
        if page
          cms_app_layout = page.jangle_layout.try(:app_layout)
          options[:layout] ||= cms_app_layout.blank?? nil : cms_app_layout
          options[:inline] = page.content
          @jangle_page = page
          super(options, locals, &block)
        else
          raise ActionView::MissingTemplate.new([path], path, "CMS page not found", nil)
        end
      else
        super(options, locals, &block)
      end
    end
  end
end

ActionController::Base.send :include, Jangle::ControllerMethods