module CmsTagResource
  extend ActiveSupport::Concern

  included do
    attr_reader :resource

    def initialize(jangle_page, label)
      @resource = self.class.cms_tag_class.initialize_or_find(jangle_page, label)
    end
  end

  module ClassMethods
    def cms_tag_class
      cms_tag_class_name.constantize
    end

    def cms_tag_class_name
      @cms_tag_class_name ||= 'Jangle::PageBlock'
    end

    def cms_tag_class_name=(klass)
      @cms_tag_class_name = klass
    end

    def set_cms_tag_class_name(klass)
      self.cms_tag_class_name = klass
    end

    def initialize_or_find(jangle_page, label)
      self.new(jangle_page, label)
    end
  end

  module InstanceMethods
    def content=(value)
      resource.write_attribute(:content, value)
    end
    
    def content
      resource.read_attribute(:content)
    end

    def label=(value)
      resource.write_attribute(:label, value)
    end

    def label
      resource.read_attribute(:label)
    end
  end
end