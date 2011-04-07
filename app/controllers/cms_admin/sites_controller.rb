class CmsAdmin::SitesController < CmsAdmin::BaseController
  
  skip_before_filter :load_admin_cms_site
  
  before_filter :build_cms_site,  :only => [:new, :create]
  before_filter :load_cms_site,   :only => [:edit, :update, :destroy]
  
  def index
    return redirect_to :action => :new if Jangle::Site.count == 0
    @cms_sites = Jangle::Site.all
  end
  
  def new
    render
  end
  
  def edit
    render
  end
  
  def create
    @cms_site.save!
    flash[:notice] = 'Site created'
    redirect_to :action => :edit, :id => @cms_site
  rescue Mongoid::Errors::Validations
    flash.now[:error] = 'Failed to create site'
    render :action => :new
  end
  
  def update
    @cms_site.update_attributes!(params[:cms_site])
    flash[:notice] = 'Site updated'
    redirect_to :action => :edit, :id => @cms_site
  rescue Mongoid::Errors::Validations
    flash.now[:error] = 'Failed to update site'
    render :action => :edit
  end
  
  def destroy
    @cms_site.destroy
    flash[:notice] = 'Site deleted'
    redirect_to :action => :index
  end
  
protected
  
  def build_cms_site
    @cms_site = Jangle::Site.new(params[:cms_site])
    @cms_site.hostname ||= request.host.downcase
  end
  
  def load_cms_site
    @cms_site = Jangle::Site.find(params[:id])
  rescue Mongoid::Errors::DocumentNotFound
    flash[:error] = 'Site not found'
    redirect_to :action => :index
  end
  
end