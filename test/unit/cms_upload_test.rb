require File.expand_path('../test_helper', File.dirname(__FILE__))

class Jangle::UploadTest < ActiveSupport::TestCase
  
  def test_validations
    assert_no_difference 'Jangle::Upload.count' do
      upload = Jangle::Upload.create
      assert upload.errors.present?
      assert_has_errors_on upload, [:file_file_name]
    end
  end
  
  def test_create
    assert_difference 'Jangle::Upload.count' do
      cms_sites(:default).cms_uploads.create(
        :file => fixture_file_upload('files/valid_image.jpg')
      )
    end
  end
  
  def test_create_failure
    assert_no_difference 'Jangle::Upload.count' do
      cms_sites(:default).cms_uploads.create(:file => '')
    end
  end
end
