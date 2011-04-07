Rails.application.routes.draw do
  
  namespace :jangle, :path => Jangle.config.admin_route_prefix, :except => :show do
    get '/' => redirect(Jangle.config.admin_route_redirect)
    resources :pages do
      member do 
        match :form_blocks
        match :toggle_branch
      end
      collection do
        match :reorder
      end
    end
    resources :sites
    resources :layouts
    resources :snippets
    resources :uploads, :only => [:create, :destroy]
  end
  
  scope :controller => :cms_content do
    get File.join(Jangle.config.cms_css_path, ':id') => :render_css, :as => 'cms_css'
    get File.join(Jangle.config.cms_js_path, ':id')  => :render_js,  :as => 'cms_js'
    get '/'             => :render_html,  :as => 'cms_html',  :path => '(*cms_path)'
  end
  
end
