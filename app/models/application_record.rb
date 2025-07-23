class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class


  class << self
    # Generate a Global ID for a model
    # without loading the record, so we can
    # create GlobalIDs without N+1
    #
    # @param id [Integer] the id of the record
    # @return [String] the Global ID as a gid param (base64 encoded)
    def global_id_for(id)
      GlobalID.new(
        URI::GID.build(app: GlobalID.app, model_name: self.name, model_id: id)
      ).to_param
    end
  end
end
