class Jangle::SnippetsController < Jangle::BaseController
  
  before_filter :build_jangle_snippet, :only => [:new, :create]
  before_filter :load_jangle_snippet,  :only => [:edit, :update, :destroy]
  
  def index
    return redirect_to :action => :new if @jangle_site.jangle_snippets.count == 0
    @jangle_snippets = @jangle_site.jangle_snippets.order_by([ :label, :asc ]).all
  end
  
  def new
    render
  end
  
  def edit
    render
  end
  
  def create
    @jangle_snippet.save!
    flash[:notice] = 'Snippet created'
    redirect_to :action => :edit, :id => @jangle_snippet
  rescue Mongoid::Errors::Validations
    flash.now[:error] = 'Failed to create snippet'
    render :action => :new
  end
  
  def update
    @jangle_snippet.update_attributes!(params[:jangle_snippet])
    flash[:notice] = 'Snippet updated'
    redirect_to :action => :edit, :id => @jangle_snippet
  rescue Mongoid::Errors::Validations
    flash.now[:error] = 'Failed to update snippet'
    render :action => :edit
  end
  
  def destroy
    @jangle_snippet.destroy
    flash[:notice] = 'Snippet deleted'
    redirect_to :action => :index
  end
  
protected
  
  def build_jangle_snippet
    @jangle_snippet = @jangle_site.jangle_snippets.new(params[:jangle_snippet])
  end
  
  def load_jangle_snippet
    @jangle_snippet = @jangle_site.jangle_snippets.find(params[:id])
  rescue Mongoid::Errors::DocumentNotFound
    flash[:error] = 'Snippet not found'
    redirect_to :action => :index
  end
end
