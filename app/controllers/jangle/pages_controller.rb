class Jangle::PagesController < Jangle::BaseController
  
  before_filter :check_for_layouts, :only => [:new, :edit]
  before_filter :build_jangle_page,    :only => [:new, :create]
  before_filter :load_jangle_page,     :only => [:edit, :update, :destroy]
  before_filter :preview_jangle_page,  :only => [:create, :update]
  before_filter :build_upload_file, :only => [:new, :edit]
  
  def index
    return redirect_to :action => :new if @jangle_site.jangle_pages.count == 0
    @jangle_pages = [@jangle_site.jangle_pages.root].compact
  end
  
  def new
    render
  end
  
  def edit
    render
  end
  
  def create
    @jangle_page.save!
    flash[:notice] = 'Page saved'
    redirect_to :action => :edit, :id => @jangle_page
  rescue Mongoid::Errors::Validations
    flash.now[:error] = 'Failed to create page'
    render :action => :new
  end
  
  def update
    @jangle_page.save!
    flash[:notice] = 'Page updated'
    redirect_to :action => :edit, :id => @jangle_page
  rescue Mongoid::Errors::Validations => e
    flash.now[:error] = 'Failed to update page'
    render :action => :edit
  end
  
  def destroy
    @jangle_page.destroy
    flash[:notice] = 'Page deleted'
    redirect_to :action => :index
  end
  
  def form_blocks
    @jangle_page = @jangle_site.jangle_pages.find_by_id(params[:id]) || Jangle::Page.new
    @jangle_page.jangle_layout = @jangle_site.jangle_layouts.find_by_id(params[:layout_id])
  end
  
  def toggle_branch
    @jangle_page = @jangle_site.jangle_pages.find(params[:id])
    s   = (session[:jangle_page_tree] ||= [])
    id  = @jangle_page.id.to_s
    s.member?(id) ? s.delete(id) : s << id
  rescue Mongoid::Errors::DocumentNotFound
    # do nothing
  end
  
  def reorder
    (params[:jangle_page] || []).each_with_index do |id, index|
      if (jangle_page = Jangle::Page.find_by_id(id))
        jangle_page.update_attribute(:position, index)
      end
    end
    render :nothing => true
  end
  
protected

  def check_for_layouts
    if Jangle::Layout.count == 0
      flash[:error] = 'No Layouts found. Please create one.'
      redirect_to new_jangle_layout_path
    end
  end
  
  def build_jangle_page
    @jangle_page = @jangle_site.jangle_pages.new(params[:jangle_page])
    @jangle_page.parent ||= (Jangle::Page.find_by_id(params[:parent_id]) || @jangle_site.jangle_pages.root)
    @jangle_page.jangle_layout ||= (@jangle_page.parent && @jangle_page.parent.jangle_layout || @jangle_site.jangle_layouts.first)
  end
  
  def build_upload_file
    @upload = Jangle::Upload.new
  end
  
  def load_jangle_page
    @jangle_page = @jangle_site.jangle_pages.find(params[:id])
    @jangle_page.attributes = params[:jangle_page]
    @jangle_page.jangle_layout ||= (@jangle_page.parent && @jangle_page.parent.jangle_layout || @jangle_site.jangle_layouts.first)
  rescue Mongoid::Errors::DocumentNotFound
    flash[:error] = 'Page not found'
    redirect_to :action => :index
  end
  
  def preview_jangle_page
    if params[:preview]
      layout = @jangle_page.jangle_layout.app_layout.blank?? false : @jangle_page.jangle_layout.app_layout
      @jangle_page.content(true)
      render :inline => @jangle_page.render(jangle_context), :layout => layout
    end
  end
end
