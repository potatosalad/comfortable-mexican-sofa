class CmsGenerator < Rails::Generators::Base
  include Thor::Actions
  
  source_root File.expand_path('../../..', __FILE__)
  
  def generate_initialization
    copy_file 'config/initializers/comfortable_mexican_sofa.rb', 'config/initializers/comfortable_mexican_sofa.rb'
  end
  
  def generate_public_assets
    directory 'public/stylesheets/comfortable_mexican_sofa', 'public/stylesheets/comfortable_mexican_sofa'
    directory 'public/javascripts/comfortable_mexican_sofa', 'public/javascripts/comfortable_mexican_sofa'
    directory 'public/images/comfortable_mexican_sofa', 'public/images/comfortable_mexican_sofa'
  end
  
  def generate_cms_seeds
    directory 'db/cms_seeds', 'db/cms_seeds'
  end
  
  def show_readme
    readme 'lib/generators/README'
  end
end