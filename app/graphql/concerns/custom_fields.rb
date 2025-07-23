module CustomFields
  extend ActiveSupport::Concern
  module ClassMethods

    # Add basic timestamp fields to an object
    def timestamp_fields
      field :created_at, GraphQL::Types::ISO8601DateTime, null: false
      field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
    end

    # Creates a dataloaded field for a polymorphic association
    def polymorphic_field(name, type_class = Types::AnyNodeType, opts = { null: true })
      field "#{name}_uuid", String, null: true
      define_method("#{name}_uuid") do
        # Check if we have a `method` argument passed to the options
        return object["#{name}_uuid"] if object.is_a?(Hash) && object.key?("#{name}_uuid")
        column = opts[:method]
        column ||= name
        reflection = object.class.reflections[column.to_s]
        return unless object.try(reflection.foreign_key)
        ::Extensions::Schema::GlobalId::Resolver.create_uuid(object.try(reflection.foreign_type), object.try(reflection.foreign_key), column_name: reflection.options[:primary_key] || :id)
      end


      field name, type_class, **opts
      define_method(name) do
        # Check if we have a `method` argument passed to the options
        return object[name] if object.is_a?(Hash) && object.key?(name)
        column = opts[:method]
        column ||= name
        reflection = object.class.reflections[column.to_s]
        class_name = object.send(reflection.foreign_type)
        return nil unless class_name
        return unless ::Zavy360Schema.class_to_type_map.keys.map(&:polymorphic_name).include?(class_name)
        return unless object.send(reflection.foreign_key)
        primary_key = reflection.options[:primary_key] || :id
        dataloader.with(::GraphQL::Dataloader::ActiveRecordSource, class_name.constantize, find_by: primary_key).load(object.send(reflection.foreign_key))
      end
    end


    # Creates a dataloaded field for a belongs_to association
    def async_field(name, type, opts = { null: true })
      field name, type, **opts
      define_method(name) do
        # Check if we have a `method` argument passed to the options
        column = opts[:method]
        column ||= name
        next object[column] if object.is_a?(Hash) && object.key?(column)
        dataloader.with(::Sources::Association, column).load(object)
      end
    end
  end

  # Makes them available on classes
  included do
    extend ClassMethods
  end

  # Allow including them in modules and interfaces
  extend ClassMethods
end