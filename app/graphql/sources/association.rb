# Rewrite of ::GraphQL::Dataloader::ActiveRecordAssociationSource to support
# nested associations and custom processing of the association afterwards
# official docs: https://graphql-ruby.org/dataloader/sources.html
# app/graphql/sources/association.rb
class Sources::Association < ::GraphQL::Dataloader::ActiveRecordAssociationSource
  attr_accessor :association_name, :subdomain

  class << self

    # Generate a batch key for the association
    def batch_key_for(association, scope = nil, **options)
      if scope
        [association, scope.to_sql, options]
      else
        [association, options]
      end
    end

    # Check if a record has loaded an association and resolve nested associations
    #
    # @param [ActiveRecord::Base] record
    # @param [String, Symbol, Hash, Array] association_name
    # @return [Boolean]
    def loaded?(record, associations)
      return false unless record
      if record.is_a?(Array) || record.is_a?(ActiveRecord::Associations::CollectionProxy)
        return record.all? { |r| loaded?(r, associations) }
      end
      return true if record.is_a?(OpenStruct) && record.respond_to?(associations)
      case associations
      when String, Symbol
        return record.association(associations).loaded?
      when Array
        return associations.all? { |assoc| loaded?(record, assoc) }
      when Hash
        return associations.keys.all? do |key|
          next false unless record.association(key).loaded?
          loaded?(record.send(key), associations[key])
        end
      end
    end
  end

  def initialize(associations, scope = nil, subdomain: nil)
    super(associations, scope)
    self.subdomain          = subdomain
    self.association_name   = associations.keys.first if associations.is_a?(Hash)
    self.association_name   = associations.first      if associations.is_a?(Array)
    self.association_name ||= associations
  end


  # Override the load method to apply custom processing
  # after loading the association. This way we can pass
  # a proc to iterate the preloaded associations after
  # preloading.
  def load(value, prepare: nil)
    return unless value
    data = if value.is_a?(::OpenStruct) && value.respond_to?(self.association_name)
              value = value.try(self.association_name)
           elsif self.class.loaded?(value, @association)
              value.association(self.association_name).target
           else
             result_key = result_key_for(value)
             if @results.key?(result_key)
               result_for(result_key)
             else
               @pending[result_key] ||= value
               sync([result_key])
               result_for(result_key)
             end
           end
    return data unless prepare.present?
    prepare.call(data)
  # Re-raise critical exceptions to avoid swallowing them
  rescue SystemStackError, FiberError, SignalException, SyntaxError, NoMemoryError, LoadError => critical_exception
    raise critical_exception
  # Rescue other exceptions to avoid leaving this Fiber dangling
  rescue => error
    Appsignal.report_error(error)
    nil
  end

  def fetch(records)
    if self.subdomain
      # Ensure we switch to the correct tenant if subdomain is provided
      ::Apartment::Tenant.switch(self.subdomain) do
        fetch_items(records)
      end
    else
      fetch_items(records)
    end
  # Re-raise critical exceptions to avoid swallowing them
  rescue SystemStackError, FiberError, SignalException, SyntaxError, NoMemoryError, LoadError => critical_exception
    raise critical_exception
  # Rescue other exceptions to avoid leaving this Fiber dangling
  rescue => error
    Appsignal.report_error(error)
    records.map { nil }
  end

  def fetch_items(records)
    record_classes = Set.new.compare_by_identity
    associated_classes = Set.new.compare_by_identity
    records.each do |record|
      if record_classes.add?(record.class)
        reflection = record.class.reflect_on_association(self.association_name)
        if !reflection.polymorphic? && reflection.klass
          associated_classes.add(reflection.klass)
        end
      end
    end

    available_records = []
    associated_classes.each do |assoc_class|
      already_loaded_records = dataloader.with(RECORD_SOURCE_CLASS, assoc_class).results.values
      available_records.concat(already_loaded_records)
    end

    ::ActiveRecord::Associations::Preloader.new(records: records, associations: @association, available_records: available_records, scope: @scope).call

    loaded_associated_records = records.map { |r| r.public_send(self.association_name) }
    records_by_model = {}
    loaded_associated_records.each do |record|
      if record.is_a?(Array) || record.is_a?(ActiveRecord::Associations::CollectionProxy)
        record.each do |rec|
          next unless rec
          updates = records_by_model[rec.class] ||= {}
          updates[rec.id] = rec
        end
      elsif record
        updates = records_by_model[record.class] ||= {}
        updates[record.id] = record
      end
    end

    if @scope.nil?
      # Don't cache records loaded via scope because they might have reduced `SELECT`s
      # Could check .select_values here?
      records_by_model.each do |model_class, updates|
        dataloader.with(RECORD_SOURCE_CLASS, model_class).merge(updates)
      end
    end

    loaded_associated_records
  end
end