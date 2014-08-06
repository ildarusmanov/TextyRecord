require 'json'

module TextyRecord
  class Base
    @@storage_file_path = 'database.json'

    def self.storage_file_path
      @@storage_file_path
    end

    def self.class_name
      self.name.downcase
    end

    def self.all
      data = load
      collection = []
      data[self.class_name].each_value do |row|
        collection.push self.build_record(row)
      end
      collection
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

    def self.first
      data = load
      id_key = data[self.class_name].keys.first
      return self.build_record(data[self.class_name][id_key]) if data[self.class_name].has_key? id_key

      nil
    end

    def initialize(attributes = {})
      @attributes = {}
      @attributes.merge!(id: nil) unless @attributes.has_key? :id

      attributes.each_pair do |k, v|
        @attributes.merge!( { k.to_sym => v } )
        build_attribute_methods(k)
      end

      self
    end

    def attributes
      @attributes
    end

    def new_record?
      @attributes[:id].nil?
    end

    def before_save
      if new_record?
        last_record = self.class.last
        new_record_id = 1
        new_record_id = last_record.id + 1 unless last_record.nil?
        @attributes.merge!(id: new_record_id)
      end
    end

    def before_destroy
    end

    def save
      before_save
      data = self.class.load
      data[self.class.class_name].merge!({hash_id_key => @attributes})
      self.class.write(data)

      self
    end

    def destroy
      before_destroy
      data = self.class.load
      data[self.class.class_name].delete(hash_id_key)
      self.class.write(data)
    end

    private

    def build_attribute_methods(attribute)
      eval "def #{attribute}; @attributes[:#{attribute}]; end"
      eval "def #{attribute}=(val); @attributes[:#{attribute}] = val; end"
    end

    def hash_id_key
      "id#{@attributes[:id]}"
    end

    def self.load
      content = File.read(self.storage_file_path)
      data = JSON.parse(content)
      data[self.class_name] = {} unless data.has_key? class_name
      data
    end

    def self.write(data)
      data[self.class_name] = {} unless data.has_key? class_name
      File.open(self.storage_file_path, 'w+') do |f|
        f.write(data.to_json)
      end
    end

    def self.build_record(attributes)
      self.new(attributes)
    end
  end
end


