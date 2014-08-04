require 'json'

module TextyRecord
  class Base
    DB_FILE_PATH =  '/home/wajox/database.json'

    def initialize(attributes = {})
      @new_record = attributes.has_key? :id
      @attributes = attributes
      @attributes.keys.each { |attr| build_attribute_methods(attr) }
    end

    def self.load
      content = File.read(DB_FILE_PATH)
      JSON.parse(content)
    end

    def self.write(data)
      File.open(DB_FILE_PATH, 'w') do |f|
        f.write(data.to_json)
      end
    end

    def self.class_name
      self.name.downcase
    end

    def self.find(id)
      data = load
      id_key = "id#{id}"
      return self.build_record(data[self.class_name][id_key]) if data[self.class_name].has_key? id_key

      nil
    end

    def self.last
      data = load
      id_key = data[self.class_name].keys.last
      return self.build_record(data[self.class_name][id_key]) if data[self.class_name].has_key? id_key

      nil
    end

    def self.build_record(attributes)
      self.new(attributes)
    end

    def build_attribute_methods(attribute)
      eval "def #{attribute}; @attributes['#{attribute}']; end"
      eval "def #{attribute}=(val); @attributes['#{attribute}'] = val; end"
    end

    def attributes
      @attributes
    end

    def save
      @attributes.merge!(id: Time.new.to_i) unless @attributes.has_key? :id
      data = load
      data[self.class_name]["id#{@attributes[:id]}"] = @attributes
      write(data)
    end
  end
end
