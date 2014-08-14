module TextyRecord
  module Query
    class << self;
      def query
        @query || = TextyRecord::Query::Base.new(self)
      end

      def where(conditions)
        query.where(conditions)
      end

      def limit(limit)
        query.limit(limit)
      end

      def all
        query.build_from_attributes_collection
      end

      def first
        query.first
      end

      def find(id)
        query.find(id)
      end

      def update(attributes)
        query.update(attributes)
      end
    end

    class Base
      def initialize(klass)
        @klass= klass
      end

      def for(class_name)
        add_params(for: class_name.to_sym)

        self
      end

      def limit(limit)
        add_params(limit: @limit)

        self
      end

      def where(conditions)
        add_params(conditions: conditions)

        self
      end

      def update(attributes)
        add_params(attributes: attributes)

        self
      end

      def all
        execute(:select)
      end

      def first
        limit(1).execute(:select).first
      end

      def find(id)
        where(id: id).execute(:find)
      end

      def execute(command)
        set_command(command).for(class_name)
        result = storage.execute_query(query)
        @params = {}

        if result.is_a? Array
          build_from_attributes_collection(result)
        elsif result.is_a? Hash
          build_from_attributes(result)
        else
          result
        end
      end

      private

      def set_command(command)
        add_params(command: command)

        self
      end

      def build_from_attributes_collection(result)
        @klass. build_from_attributes_collection(result)
      end

      def build_from_attributes(result)
        @klass.build_from_attributes(result)
      end

      def storage
        @klass.storage
      end

      def class_name
        @klass.name
      end

      def add_params(params)
        @params ||= {}
        @params.merge!(params)
      end

      def query
        @params
      end
    end
  end
end
