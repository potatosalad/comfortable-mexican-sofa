Rails.application.routes.draw do
  
  namespace :cms_admin, :path => ComfortableMexicanSofa.config.admin_route_prefix, :except => :show do
    get '/' => redirect(ComfortableMexicanSofa.config.admin_route_redirect)
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
    get File.join(ComfortableMexicanSofa.config.cms_css_path, ':id') => :render_css, :as => 'cms_css'
    get File.join(ComfortableMexicanSofa.config.cms_js_path, ':id')  => :render_js,  :as => 'cms_js'
    get '/'             => :render_html,  :as => 'cms_html',  :path => '(*cms_path)'
  end
  
end
