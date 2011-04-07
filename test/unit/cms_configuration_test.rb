require File.expand_path('../test_helper', File.dirname(__FILE__))

class CmsConfigurationTest < ActiveSupport::TestCase
  
  def test_configuration_presense
    assert config = Jangle.configuration
    assert_equal 'Jangle MicroCMS', config.cms_title
    assert_equal 'Jangle::HttpAuth', config.authentication
    assert_equal nil, config.seed_data_path
    assert_equal 'cms-admin', config.admin_route_prefix
    assert_equal '/cms-admin/pages', config.admin_route_redirect
    assert_equal true, config.disable_irb
    assert_equal true, config.enable_caching
  end
  
  def test_initialization_overrides
    Jangle.configuration.cms_title = 'New Title'
    assert_equal 'New Title', Jangle.configuration.cms_title
  end
  
end