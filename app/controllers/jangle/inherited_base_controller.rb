module Jangle
  class InheritedBaseController < InheritedResources::Base
    include Jangle::Routing::SiteDispatcher
  end
end