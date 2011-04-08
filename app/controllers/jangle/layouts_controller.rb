class Jangle::LayoutsController < Jangle::BaseController

  before_filter :build_jangle_layout, :only => [:new, :create]
  before_filter :load_jangle_layout,  :only => [:edit, :update, :destroy]

  def index
    return redirect_to :action => :new if @jangle_site.jangle_layouts.count == 0
    @jangle_layouts = @jangle_site.jangle_layouts.roots
  end

  def new
    render
  end

  def edit
    render
  end

  def create
    @jangle_layout.save!
    flash[:notice] = 'Layout created'
    redirect_to :action => :edit, :id => @jangle_layout
  rescue Mongoid::Errors::Validations
    flash.now[:error] = 'Failed to create layout'
    render :action => :new
  end

  def update
    @jangle_layout.update_attributes!(params[:jangle_layout])
    flash[:notice] = 'Layout updated'
    redirect_to :action => :edit, :id => @jangle_layout
  rescue Mongoid::Errors::Validations
    flash.now[:error] = 'Failed to update layout'
    render :action => :edit
  end

  def destroy
    @jangle_layout.destroy
    flash[:notice] = 'Layout deleted'
    redirect_to :action => :index
  end

protected
  def build_jangle_layout
    @jangle_layout = @jangle_site.jangle_layouts.build(params[:jangle_layout])
    @jangle_layout.parent  ||= Jangle::Layout.find_by_id(params[:parent_id])
    @jangle_layout.content ||= '{{ cms:page:content:text }}'
  end
  
  def load_jangle_layout
    puts @jangle_site.jangle_layouts.map(&:_id).inspect
    @jangle_layout = @jangle_site.jangle_layouts.find(params[:id])
  rescue Mongoid::Errors::DocumentNotFound
    flash[:error] = 'Layout not found'
    redirect_to :action => :index
  end
end