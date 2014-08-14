require 'json'

require File.join(File.dirname(__FILE__), 'texty_record', 'query_builder')
require File.join(File.dirname(__FILE__), 'texty_record', 'exceptions')
require File.join(File.dirname(__FILE__), 'texty_record', 'query_parser')
require File.join(File.dirname(__FILE__), 'texty_record', 'json_file_storage')
require File.join(File.dirname(__FILE__), 'texty_record', 'attributes')
require File.join(File.dirname(__FILE__), 'texty_record', 'validations')

module TextyRecord
  class Base
    extend TextyRecord::QueryBuilder
    extend TextyRecord::Validations
    include TextyRecord::Attributes::ClassMethods
    include TextyRecord::Validations::ClassMethods
    include TextyRecord::Exceptions
    include TextyRecord::QueryBuilder::ClassMethods

    add_validation :unique, :id
    add_validation :numeric, :id

    def initialize(attributes = {})
      initialize_attributes(attributes)

      self
    end

    def before_save
      validate
    end

    def new_record?
      id.nil?
    end

    class << self
      def class_name
        self.name.to_sym
      end

      def build_from_attributes(attributes)
        self.new(attributes)
      end

      def build_from_attributes_collection(collection_attributes)
        collection = []
        collection_attributes.each { |attributes| collection.push build_from_attributes(attributes) }
        collection
      end

      def storage
        TextyRecord::JsonFileStorage
      end
    end
  end
end
