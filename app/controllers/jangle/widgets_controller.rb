class Jangle::WidgetsController < Jangle::BaseController

  before_filter :check_for_templates, :only => [:new, :edit]
  before_filter :build_jangle_widget,    :only => [:new, :create]
  before_filter :load_jangle_widget,     :only => [:edit, :update, :destroy]
  before_filter :preview_jangle_widget,  :only => [:create, :update]
  before_filter :build_upload_file, :only => [:new, :edit]
  
  def index
    return redirect_to :action => :new if @jangle_site.jangle_widgets.count == 0
    @jangle_widgets = @jangle_site.jangle_widgets.roots
  end
  
  def new
    render
  end
  
  def edit
    render
  end
  
  def create
    @jangle_widget.save!
    flash[:notice] = 'Widget saved'
    redirect_to :action => :edit, :id => @jangle_widget
  rescue Mongoid::Errors::Validations
    flash.now[:error] = 'Failed to create widget'
    render :action => :new
  end
  
  def update
    @jangle_widget.save!
    flash[:notice] = 'Widget updated'
    redirect_to :action => :edit, :id => @jangle_widget
  rescue Mongoid::Errors::Validations => e
    flash.now[:error] = 'Failed to update widget'
    render :action => :edit
  end
  
  def destroy
    @jangle_widget.destroy
    flash[:notice] = 'Widget deleted'
    redirect_to :action => :index
  end
  
  def form_blocks
    @jangle_widget = @jangle_site.jangle_widgets.find_by_id(params[:id]) || Jangle::Widget.new
    @jangle_widget.jangle_template = @jangle_site.jangle_templates.find_by_id(params[:template_id])
  end
  
  def toggle_branch
    @jangle_widget = @jangle_site.jangle_widgets.find(params[:id])
    s   = (session[:jangle_widget_tree] ||= [])
    id  = @jangle_widget.id.to_s
    s.member?(id) ? s.delete(id) : s << id
  rescue Mongoid::Errors::DocumentNotFound
    # do nothing
  end
  
  def reorder
    (params[:jangle_widget] || []).each_with_index do |id, index|
      if (jangle_widget = Jangle::Widget.find_by_id(id))
        jangle_widget.update_attribute(:position, index)
      end
    end
    render :nothing => true
  end
  
protected

  def check_for_templates
    if Jangle::Template.count == 0
      flash[:error] = 'No Templates found. Please create one.'
      redirect_to new_jangle_template_path
    end
  end
  
  def build_jangle_widget
    @jangle_widget = @jangle_site.jangle_widgets.new(params[:jangle_widget])
    @jangle_widget.parent ||= Jangle::Widget.find_by_id(params[:parent_id])
    @jangle_widget.jangle_template ||= (@jangle_widget.parent && @jangle_widget.parent.jangle_template || @jangle_site.jangle_templates.first)
  end
  
  def build_upload_file
    @upload = Jangle::Upload.new
  end
  
  def load_jangle_widget
    @jangle_widget = @jangle_site.jangle_widgets.find(params[:id])
    @jangle_widget.attributes = params[:jangle_widget]
    @jangle_widget.jangle_template ||= (@jangle_widget.parent && @jangle_widget.parent.jangle_template || @jangle_site.jangle_templates.first)
  rescue Mongoid::Errors::DocumentNotFound
    flash[:error] = 'Widget not found'
    redirect_to :action => :index
  end
  
  def preview_jangle_widget
    if params[:preview]
      @jangle_widget.content(true)
      render :inline => @jangle_widget.render(jangle_context), :template => nil
    end
  end
end