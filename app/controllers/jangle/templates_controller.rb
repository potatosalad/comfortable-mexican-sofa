class Jangle::TemplatesController < Jangle::BaseController

  before_filter :build_jangle_template, :only => [:new, :create]
  before_filter :load_jangle_template,  :only => [:edit, :update, :destroy]

  def index
    return redirect_to :action => :new if @jangle_site.jangle_templates.count == 0
    @jangle_templates = @jangle_site.jangle_templates.roots
  end

  def new
    render
  end

  def edit
    render
  end

  def create
    @jangle_template.save!
    flash[:notice] = 'Template created'
    redirect_to :action => :edit, :id => @jangle_template
  rescue Mongoid::Errors::Validations
    flash.now[:error] = 'Failed to create template'
    render :action => :new
  end

  def update
    @jangle_template.update_attributes!(params[:jangle_template])
    flash[:notice] = 'Template updated'
    redirect_to :action => :edit, :id => @jangle_template
  rescue Mongoid::Errors::Validations
    flash.now[:error] = 'Failed to update template'
    render :action => :edit
  end

  def destroy
    @jangle_template.destroy
    flash[:notice] = 'Template deleted'
    redirect_to :action => :index
  end

protected
  def build_jangle_template
    @jangle_template = @jangle_site.jangle_templates.build(params[:jangle_template])
    @jangle_template.parent  ||= Jangle::Template.find_by_id(params[:parent_id])
    @jangle_template.content ||= '{{ cms:template:content:text }}'
  end
  
  def load_jangle_template
    puts @jangle_site.jangle_templates.map(&:_id).inspect
    @jangle_template = @jangle_site.jangle_templates.find(params[:id])
  rescue Mongoid::Errors::DocumentNotFound
    flash[:error] = 'Template not found'
    redirect_to :action => :index
  end
end