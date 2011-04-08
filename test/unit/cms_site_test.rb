require File.expand_path('../test_helper', File.dirname(__FILE__))

class Jangle::SiteTest < ActiveSupport::TestCase
  
  def test_fixtures_validity
    Jangle::Site.all.each do |site|
      assert site.valid?, site.errors.full_messages.to_s
    end
  end
  
  def test_validation
    site = Jangle::Site.new
    assert site.invalid?
    assert_has_errors_on site, [:label, :hostname]
    
    site = Jangle::Site.new(:label => 'My Site', :hostname => 'http://mysite.com')
    assert site.invalid?
    assert_has_errors_on site, :hostname
    
    site = Jangle::Site.new(:label => 'My Site', :hostname => 'mysite.com')
    assert site.valid?
  end
  
  def test_cascading_destroy
    assert_difference 'Jangle::Site.count', -1 do
      assert_difference 'Jangle::Layout.count', -3 do
        assert_difference 'Jangle::Page.count', -2 do
          assert_difference 'Jangle::Snippet.count', -1 do
            jangle_sites(:default).destroy
          end
        end
      end
    end
  end
  
  def test_options_for_select
    assert_equal 1, Jangle::Site.options_for_select.size
    assert_equal 'Default Site (test.host)', Jangle::Site.options_for_select[0][0]
  end
  
end