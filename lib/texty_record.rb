require 'json'

module TextyRecord
  autoload :QueryBuilder, 'texty_record/query_builder'
  autoload :Exceptions, 'texty_record/exceptions'
  autoload :QueryParser, 'texty_record/query_parser'
  autoload :JsonFileStorage, 'texty_record/json_file_storage'
  autoload :Attributes, 'texty_record/attributes'
  autoload :Validations, 'texty_record/validations'

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
        collection_attributes.map { |attributes| build_from_attributes(attributes) }
      end

      def storage
        TextyRecord::JsonFileStorage
      end
    end
  end
end
