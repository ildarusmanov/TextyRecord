module TextyRecord
  module Attributes
    module ClassMethods
      def initialize_attributes(attributes)
        @attributes = {}
        attributes.each_pair do |k, v|
          write_attribute(k.to_sym, v)
          build_attribute_methods(k) unless k == :id
        end
      end

      def attributes
        @attributes
      end

      def read_attribute(attribute_name)
        @attributes[attribute_name]
      end

      def write_attribute(attribute_name, value)
        @attributes.merge!({ attribute_name => value })
      end

      def id
        return nil unless @attributes.has_key? :id
        @attributes[:id]
      end

      private

      def build_attribute_methods(attribute)
        self.class.send(:define_method, attribute) { read_attribute(attribute) }
        self.class.send(:define_method, "#{attribute}=") { |v| write_attribute(attribute, v) }
      end
    end
  end
end
