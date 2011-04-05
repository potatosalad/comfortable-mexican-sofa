class CmsAdmin::UploadsController < CmsAdmin::BaseController
  
  before_filter :load_cms_upload, :only => :destroy
  
  def index
    render
  end
  
  def create
    @cms_upload = @cms_site.cms_uploads.create!(:file => params[:file])
    render :partial => 'file', :object => @cms_upload
  rescue Mongoid::Errors::Validations
    render :nothing => true, :status => :bad_request
  end
  
  def destroy
    @cms_upload.destroy
  end
  
protected
  
  def load_cms_upload
    @cms_upload = @cms_site.cms_uploads.find(params[:id])
  rescue Mongoid::Errors::DocumentNotFound
    render :nothing => true
  end
end
