module TextyRecord
  module Validations
    def add_validation(type, field, options = {})
      @@validations ||= {}
      @@validations.merge!({ field => [] }) unless @@validations.has_key? field
      @@validations[field].push({ type: type, options: options })
    end

    def validations
      @@validations
    end

    module ClassMethods
      def write_validation_error(field, error)
        @validation_errors ||= {}
        @validation_errors.merge!({ field => [] }) unless @validation_errors.has_key? field
        @validation_errors[field] .push(error)
      end

      def validate
        @validation_errors = {}
        return true if self.class.validations.nil?
        self.class.validations.each_key do |field|
          validate_field(field)
        end
        @validation_errors.count == 0
      end

      def validate_field(field)
        self.class.validations[field].each do |field_validation|
          self.send("validate_#{field_validation[:type]}".to_sym, field, field_validation[:options])
        end
      end

      def validate_numeric(field, options)
        value = read_attribute(field)

        return if value.nil?

        unless value.is_a? Numeric
          write_validation_error(field, 'Is not numeric value')
        end
      end

      def validate_unique(field, options)
        value = read_attribute(field)

        return if value.nil?

        if self.class.where({ field => value }).limit(1).execute(:select).count > 0
          write_validation_error(field, 'Is not unique value')
        end
      end

      def validation_errors
        @validation_errors
      end
    end
  end
end
