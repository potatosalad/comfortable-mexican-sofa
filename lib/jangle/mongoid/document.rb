module Jangle
  module Mongoid
    module Document
      def find_by_id(id)
        return if id.nil?
        self.find(id)
      end

      def find_by_slug(*slug)
        return if slug.blank?
        self.where(:slug => slug).first
      end

      def order(order_stmt)
        orders = order_stmt.to_s.split(',')
        orders.map! do |order|
          order.split.tap do |x|
            x[1] ||= :asc
          end.map { |o| o.to_sym }
        end
        self.order_by(*orders)
      end
    end
  end
end

Mongoid::Document.class_eval do
  def self.included(base)
    base.extend Jangle::Mongoid::Document
  end
end