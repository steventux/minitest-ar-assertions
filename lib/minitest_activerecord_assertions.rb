module MiniTest

  module ActiveRecordAssertions
    
    class ValidationsTypeFactory
      def self.by_name(name)
        types = {
          :length => ActiveModel::Validations::LengthValidator,
          :format => ActiveModel::Validations::FormatValidator
        }
        return types[name]
      end
    end

    def assert_association(clazz, association, associate, options={})
      reflected_assoc = clazz.reflect_on_association(associate)
      flunk "#{clazz} has no association with #{associate}" if reflected_assoc.nil?
      assert_equal association, reflected_assoc.macro
      options.each do |key, value|
        assert_equal value, reflected_assoc.options[key]
      end
    end
    
    def assert_validates_presence_of(clazz, attribute)
      validators = clazz._validators[attribute]
      refute validators.empty?, "#{clazz} does not have validations for #{attribute}"
      presence_validator = ::ActiveModel::Validations::PresenceValidator
      validator_classes = validators.map { |v| v.class }
      assert validator_classes.include?(presence_validator), 
        "#{clazz} does not validate_presence_of #{attribute}"
    end
    
    def assert_validates_uniqueness_of(clazz, *attributes) 
      has_validator = false
      attributes.each do |attribute|
        validators = clazz._validators[attribute]
        if validators.empty? 
          flunk "No validations for #{attribute}"    
        else
          validators.each do |validator|
            if validator.class == ::ActiveRecord::Validations::UniquenessValidator
              has_validator = (attributes.sort! == validator.attributes.sort!)
              break
            end
          end
        end
      end
      assert has_validator, "#{clazz} does not validate_uniqueness_of #{attributes}"
    end
    
    def assert_validates_numericality_of(clazz, attribute, options = {})
      validator_classes = clazz._validators[attribute].map{ |v| v.class }
      assert_includes validator_classes, 
        ::ActiveModel::Validations::NumericalityValidator,
          "#{clazz} does not validate_numericality_of #{attribute}" 
    end

    def assert_validates_inclusion_of(clazz, attribute, options = {})
      validators = clazz._validators[attribute]
      refute validators.empty?, "#{clazz} does not have validations for #{attribute}"
      inclusion_validator = ::ActiveModel::Validations::InclusionValidator
      validator_classes = validators.map { |v| v.class }
      
      if options.size > 0
        index = validators.index {|c| c if c.class == ActiveModel::Validations::InclusionValidator }
        validator = validators[index]
        assert validator_classes.include?(inclusion_validator) && validator.options == options,
          "#{clazz} does not validate_inclusion_of #{attribute} with options #{options}"

      else
        assert validator_classes.include?(inclusion_validator), 
        "#{clazz} does not validate_inclusion_of #{attribute}"
      end
    end

    def assert_validates_exclusion_of(clazz, attribute, options = {})
      validators = clazz._validators[attribute]
      refute validators.empty?, "#{clazz} does not have validations for #{attribute}"
      exclusion_validator = ::ActiveModel::Validations::ExclusionValidator
      validator_classes = validators.map { |v| v.class }
      
      if options.size > 0
        index = validators.index {|c| c if c.class == ActiveModel::Validations::ExclusionValidator }
        validator = validators[index]
        assert validator_classes.include?(exclusion_validator) && validator.options == options,
          "#{clazz} does not validate_exclusion_of #{attribute} with options #{options}"

      else
        assert validator_classes.include?(exclusion_validator), 
        "#{clazz} does not validate_exclusion_of #{attribute}"
      end
    end

    def assert_validates_confirmation_of(clazz, attribute, options = {})
      validators = clazz._validators[attribute]
      refute validators.empty?, "#{clazz} does not have validations for #{attribute}"
      confirmation_validator = ::ActiveModel::Validations::ConfirmationValidator
      validator_classes = validators.map { |v| v.class }
      
      if options.size > 0
        index = validators.index {|c| c if c.class == ActiveModel::Validations::ConfirmationValidator }
        validator = validators[index]
        assert validator_classes.include?(confirmation_validator) && validator.options == options,
          "#{clazz} does not validate_confirmation_of #{attribute} with options #{options}"

      else
        assert validator_classes.include?(confirmation_validator), 
        "#{clazz} does not validate_confirmation_of #{attribute}"
      end
    end

    def assert_validates(clazz, attribute, options = {})
      validators = clazz._validators[attribute]
      refute (validators.empty?), 
        "#{clazz} does not have validations for #{attribute}"

      name = options.respond_to?(:keys) ? options.keys.first.to_sym : options.to_sym
      implied_validator = ActiveRecordAssertions::ValidationsTypeFactory.by_name(name)
      validator_classes = validators.map { |v| v.class }
      assert validator_classes.include?(implied_validator),
        "#{clazz} does not validates #{attribute} for #{options.keys.first}"

      index = validators.index {|c| c if c.class == implied_validator }
      validator = validators[index]
      assert ((validator.options == options) || (validator.options == options.fetch(options.keys.first))),
        "#{clazz} does not validates #{attribute} with options #{options}"
    end
  
  end

end
