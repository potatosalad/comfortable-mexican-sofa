# From: https://github.com/locomotivecms/engine
module Jangle
  module Routing
    module SiteDispatcher

      extend ActiveSupport::Concern

      included do
        if self.respond_to?(:before_filter)
          before_filter :fetch_site

          helper_method :current_site
        end
      end

      module InstanceMethods

        protected

        def fetch_site
          Jangle.logger "[fetch site] host = #{request.host} / #{request.env['HTTP_HOST']}"
          @current_site ||= Jangle::Site.match_domain(request.host).first
        end

        def current_site
          @current_site || fetch_site
        end

        def require_site
          return true if current_site

          redirect_to admin_installation_url and return false if Account.count == 0 || Site.count == 0

          render_no_site_error and return false
        end

        def render_no_site_error
          render :template => "/admin/errors/no_site", :layout => false
        end

        def validate_site_membership
          return true if current_site.present? && current_site.accounts.include?(current_admin)

          sign_out(current_admin)
          flash[:alert] = I18n.t(:no_membership, :scope => [:devise, :failure, :admin])
          redirect_to new_admin_session_url and return false
        end

      end

    end
  end
end