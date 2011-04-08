require File.expand_path('../test_helper', File.dirname(__FILE__))

class Jangle::SnippetTest < ActiveSupport::TestCase
  
  def test_fixtures_validity
    Jangle::Snippet.all.each do |snippet|
      assert snippet.valid?, snippet.errors.full_messages.to_s
    end
  end
  
  def test_validations
    snippet = Jangle::Snippet.new
    snippet.save
    assert snippet.invalid?
    assert_has_errors_on snippet, [:label, :slug]
  end
  
  def test_method_content
    assert_equal jangle_snippets(:default).content, Jangle::Snippet.content_for('default')
    assert_equal '', Jangle::Snippet.content_for('nonexistent_snippet')
  end
  
  def test_load_from_file
    assert !Jangle::Snippet.load_from_file(jangle_sites(:default), 'default')
    
    Jangle.configuration.seed_data_path = File.expand_path('../cms_seeds', File.dirname(__FILE__))
    
    assert !Jangle::Snippet.load_from_file(jangle_sites(:default), 'bogus')
    
    assert snippet = Jangle::Snippet.load_from_file(jangle_sites(:default), 'default')
    assert_equal 'Default Snippet', snippet.label
    assert_equal 'Content for Default Snippet', snippet.content
  end
  
  def test_load_from_file_broken
    Jangle.configuration.seed_data_path = File.expand_path('../cms_seeds', File.dirname(__FILE__))
    error_message = "Failed to load from #{Jangle.configuration.seed_data_path}/test.host/snippets/broken.yml"
    assert_exception_raised RuntimeError, error_message do
      Jangle::Snippet.load_from_file(jangle_sites(:default), 'broken')
    end
  end
  
  def test_load_for_slug
    assert snippet = Jangle::Snippet.load_for_slug!(jangle_sites(:default), 'default')
    assert !snippet.new_record?
    db_content = snippet.content
    
    Jangle.configuration.seed_data_path = File.expand_path('../cms_seeds', File.dirname(__FILE__))
    assert snippet = Jangle::Snippet.load_for_slug!(jangle_sites(:default), 'default')
    assert snippet.new_record?
    file_content = snippet.content
    assert_not_equal db_content, file_content
  end
  
  def test_load_for_slug_exceptions
    assert_exception_raised ActiveRecord::RecordNotFound, 'Jangle::Snippet with slug: not_found cannot be found' do
      Jangle::Snippet.load_for_slug!(jangle_sites(:default), 'not_found')
    end
    assert !Jangle::Snippet.load_for_slug(jangle_sites(:default), 'not_found')
    
    Jangle.configuration.seed_data_path = File.expand_path('../cms_seeds', File.dirname(__FILE__))
    assert_exception_raised ActiveRecord::RecordNotFound, 'Jangle::Snippet with slug: not_found cannot be found' do
      Jangle::Snippet.load_for_slug!(jangle_sites(:default), 'not_found')
    end
    assert !Jangle::Snippet.load_for_slug(jangle_sites(:default), 'not_found')
  end
  
  def test_update_forces_page_content_reload
    snippet = jangle_snippets(:default)
    page = jangle_pages(:default)
    assert_match snippet.content, page.content
    snippet.update_attribute(:content, 'new_snippet_content')
    page.reload
    assert_match /new_snippet_content/, page.content
  end
  
end
