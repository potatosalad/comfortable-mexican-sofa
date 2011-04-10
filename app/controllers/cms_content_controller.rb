class CmsContentController < ApplicationController
  
  before_filter :load_jangle_site
  before_filter :load_jangle_page,   :only => :render_html
  before_filter :load_jangle_layout, :only => [:render_css, :render_js]
  before_filter :load_jangle_widget, :only => [:render_widget_css, :render_widget_js]
  
  caches_page :render_css, :render_js, :if => Proc.new { |c| Jangle.config.enable_caching }
  
  def render_html(status = 200)
    layout = @jangle_page.jangle_layout.app_layout.blank?? false : @jangle_page.jangle_layout.app_layout
    render :inline => @jangle_page.render(jangle_context), :layout => layout, :status => status
  end
  
  def render_css
    render :text => @jangle_layout.css, :content_type => 'text/css'
  end
  
  def render_js
    render :text => @jangle_layout.js, :content_type => 'text/javascript'
  end

  def render_widget_css
    render :text => @jangle_widget.css, :content_type => 'text/css'
  end
  
  def render_widget_js
    render :text => @jangle_widget.js, :content_type => 'text/javascript'
  end

  def to_liquid
    { 'name' => controller_name }
  end
  
protected
  
  def load_jangle_site
    @jangle_site = Jangle::Site.find_by_hostname!(Jangle.config.override_host || request.host.downcase)
  rescue Mongoid::Errors::DocumentNotFound
    render :text => 'Site Not Found', :status => 404
  end
  
  def load_jangle_page
    @jangle_page = Jangle::Page.published.load_for_full_path!(@jangle_site, "/#{params[:cms_path]}")
    return redirect_to(@jangle_page.target_page.full_path) if @jangle_page.target_page
    
  rescue Mongoid::Errors::DocumentNotFound
    if @jangle_page = Jangle::Page.published.load_for_full_path(@jangle_site, '/404')
      render_html(404)
    else
      render :text => 'Page Not Found', :status => 404
    end
  end
  
  def load_jangle_layout
    @jangle_layout = Jangle::Layout.load_for_slug!(@jangle_site, params[:id])
  rescue Mongoid::Errors::DocumentNotFound
    render :nothing => true, :status => 404
  end

  def load_jangle_widget
    @jangle_widget = Jangle::Template.load_for_slug!(@jangle_site, params[:id])
  rescue Mongoid::Errors::DocumentNotFound
    render :nothing => true, :status => 404
  end

  def jangle_context
    assigns = {
      'site'              => @jangle_site,
      'page'              => @jangle_page,
      'current_page'      => self.params[:cms_path]
    }.merge(flash.stringify_keys) # data from api

    registers = {
      :controller     => self,
      :site           => @jangle_site,
      :page           => @jangle_page
    }

    Liquid::Context.new({}, assigns, registers)
  end
  
end
