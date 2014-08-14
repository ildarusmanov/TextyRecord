module TextyRecord
  module QueryParser
    def execute_query(query)
      execute_command(query)
    end

    private

    def execute_command(query)
      return execute_find(query) if query[:command] == :find
      return execute_select(query) if query[:command] == :select
      return execute_save(query) if query[:command] == :save
      return execute_destroy(query) if query[:command] == :destroy

      raise TextyRecord::Exceptions::InvalidCommand
    end

    def execute_find(query)
      load_record(query[:for], query[:conditions][:id])
    end

    def execute_select(query)
      records = load_records(query[:for]).values
      records = records.select do |record|
        to_compare = record.select{ |k, v| query[:conditions].has_key? k }
        query[:conditions].eql?(to_compare)
      end if query.has_key? :conditions
      records = records.slice(0, query[:limit]) if query.has_key? :limit && !query[:limit].nil?
      records
    end

    def execute_save(query)
      write_record(query[:for], query[:attributes])
    end

    def execute_destroy(query)
      record = execute_find(query)
      destroy_record(query[:for], record[:id])
    end
  end
end
