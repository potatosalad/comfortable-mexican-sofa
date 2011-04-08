class Jangle::UploadsController < Jangle::BaseController
  
  before_filter :load_jangle_upload, :only => :destroy
  
  def index
    render
  end
  
  def create
    @jangle_upload = @jangle_site.jangle_uploads.create!(:file => params[:file])
    render :partial => 'file', :object => @jangle_upload
  rescue Mongoid::Errors::Validations
    render :nothing => true, :status => :bad_request
  end
  
  def destroy
    @jangle_upload.destroy
  end
  
protected
  
  def load_jangle_upload
    @jangle_upload = @jangle_site.jangle_uploads.find(params[:id])
  rescue Mongoid::Errors::DocumentNotFound
    render :nothing => true
  end
end
