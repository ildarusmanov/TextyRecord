module TextyRecord
  module QueryBuilder
    def query
      @query ||= TextyRecord::QueryBuilder::Query.new(self)
    end

    def where(conditions)
      query.where(conditions)
    end

    def limit(limit)
      query.limit(limit)
    end

    def all
      query.all
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

    def execute(command)
      query.execute(command)
    end

    module ClassMethods
      def save
        if before_save
          self.class.where(id: id).update(attributes).execute(:save)
        else
          false
        end
      end

      def destroy
        self.class.where(id: id).execute(:destroy)
      end
    end

    class Query
      def initialize(klass)
        @klass = klass
      end

      def for(class_name)
        add_params(for: class_name)

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
        result = storage.execute_query(params)
        @params = {}

        if result.is_a? Array
          build_from_attributes_collection(result)
        elsif result.is_a? Hash
          build_from_attributes(result)
        else
          result
        end
      end

      def set_command(command)
        add_params(command: command)

        self
      end

      def build_from_attributes_collection(collection_attributes)
        @klass.build_from_attributes_collection(collection_attributes)
      end

      def build_from_attributes(attributes)
        @klass.build_from_attributes(attributes)
      end

      def storage
        @klass.storage
      end

      def class_name
        @klass.name.to_sym
      end

      def add_params(params)
        @params ||= {}
        @params.merge!(params)
      end

      def params
        @params
      end
    end
  end
end
