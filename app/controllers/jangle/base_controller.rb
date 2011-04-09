class Jangle::BaseController < ActionController::Base
  
  protect_from_forgery
  
  # Authentication module must have #authenticate method
  include Jangle.config.authentication.to_s.constantize
  
  before_filter :authenticate,
                :load_admin_jangle_site
  
  layout 'jangle'

  def to_liquid
    { 'name' => controller_name }
  end

protected
  
  def load_admin_jangle_site
    hostname = Jangle.config.override_host || request.host.downcase
    @jangle_site = Jangle::Site.find_by_hostname!(hostname)
  
  rescue Mongoid::Errors::DocumentNotFound
    
    if Jangle.config.auto_manage_sites
      if Jangle::Site.count == 0
        @jangle_site = Jangle::Site.create!(:label => 'Default Site', :hostname => hostname)
      elsif Jangle::Site.count == 1
        @jangle_site = Jangle::Site.first
        @jangle_site.update_attribute(:hostname, hostname)
      end
    end
    
    unless @jangle_site
      flash[:error] = 'No Site defined for this hostname. Create it now.'
      return redirect_to(jangle_sites_path)
    end
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
