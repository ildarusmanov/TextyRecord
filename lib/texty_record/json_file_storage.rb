module TextyRecord
  class JsonFileStorage
    class << self
      include QueryParser

      def storage_file_path
        ENV['TEXTY_RECORD_JSON_STORAGE_FILE']
      end

      def load_data
        content = File.read(storage_file_path)
        JSON.parse(content, {symbolize_names: true})
      end

      def load_records(class_name)
        data = load_data
        data.merge!(class_name => {}) unless data.has_key? class_name
        data[class_name]
      end

      def load_record(class_name, record_id)
        records = load_records(class_name)
        raise TextyRecord::Exceptions::RecordNotFound unless records.has_key? "id#{record_id}".to_sym
        records["id#{record_id}".to_sym]
      end

      def write_data(data)
        File.open(storage_file_path, 'w+') do |f|
          f.write(data.to_json)
        end
      end

      def write_records(class_name, records)
        data = load_data
        data[class_name] = records
        write_data(data)
      end

      def new_record_id(class_name)
        records = load_records(class_name)
        id = 1
        id = records.values.last[:id] + 1 if records.count > 0

        id
      end

      def write_record(class_name, record_data)
        record_data.merge!(id: new_record_id(class_name)) unless record_data.has_key? :id
        records = load_records(class_name)
        records["id#{record_data[:id]}".to_sym] = record_data
        write_records(class_name, records)

        record_data
      end

      def destroy_record(class_name, record_id)
        records = load_records(class_name)
        records.delete("id#{record_id}".to_sym)
        write_records(class_name, records)
      end
    end
  end
end
