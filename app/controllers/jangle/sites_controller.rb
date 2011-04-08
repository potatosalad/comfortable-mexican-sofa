class Jangle::SitesController < Jangle::BaseController
  
  skip_before_filter :load_admin_jangle_site
  
  before_filter :build_jangle_site,  :only => [:new, :create]
  before_filter :load_jangle_site,   :only => [:edit, :update, :destroy]
  
  def index
    return redirect_to :action => :new if Jangle::Site.count == 0
    @jangle_sites = Jangle::Site.all
  end
  
  def new
    render
  end
  
  def edit
    render
  end
  
  def create
    @jangle_site.save!
    flash[:notice] = 'Site created'
    redirect_to :action => :edit, :id => @jangle_site
  rescue Mongoid::Errors::Validations
    flash.now[:error] = 'Failed to create site'
    render :action => :new
  end
  
  def update
    @jangle_site.update_attributes!(params[:jangle_site])
    flash[:notice] = 'Site updated'
    redirect_to :action => :edit, :id => @jangle_site
  rescue Mongoid::Errors::Validations
    flash.now[:error] = 'Failed to update site'
    render :action => :edit
  end
  
  def destroy
    @jangle_site.destroy
    flash[:notice] = 'Site deleted'
    redirect_to :action => :index
  end
  
protected
  
  def build_jangle_site
    @jangle_site = Jangle::Site.new(params[:jangle_site])
    @jangle_site.hostname ||= request.host.downcase
  end
  
  def load_jangle_site
    @jangle_site = Jangle::Site.find(params[:id])
  rescue Mongoid::Errors::DocumentNotFound
    flash[:error] = 'Site not found'
    redirect_to :action => :index
  end
  
end