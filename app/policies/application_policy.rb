class ApplicationPolicy
  attr_accessor :record, :pundit_user
  delegate :user,
           :organization,
           :user,
           :staff?,
           :client?,
           :manager?,
           :family_member?,
           :family_members,
           :same_family?,
           to: :pundit_user,
           allow_nil: true

  class Scope
    attr_accessor :scope,
                  :pundit_user,
                  :model

    delegate :organization,
             :user,
             :staff?,
             :client?,
             :manager?,
             :family_members,
             to: :pundit_user,
             allow_nil: true

    def initialize(pundit_user, scope)
      self.pundit_user = pundit_user
      self.model = model_for_scope(scope)
      self.scope = normalize_scope(scope)
    end


    def resolve
      scope
    end

    private

    # Ensures that the scope is an ActiveRecord::Collection
    #
    # @param [Array<ApplicationRecord> | ApplicationRecord | Class] param
    # @return [ActiveRecord::Relation]
    def normalize_scope(param)
      return param if param.is_a?(ActiveRecord::Relation)
      return param if param.is_a?(Class)
      self.model.none.or(self.model.where(self.model.primary_key => param)) if self.model.present?
    end

    # Resolve the model for a given scope argument
    #
    # @param [Array<ApplicationRecord> | ApplicationRecord | Class] param
    # @return [ActiveRecord::Base]
    def model_for_scope(param)
      return model_for_scope(param.first) if param.is_a?(Array)
      return if param.nil?
      return param.class if param.is_a?(ApplicationRecord)
      return param if param.is_a?(Class)
    end
  end

  def initialize(context, record)
    self.pundit_user = context
    self.record = record
  end

  def index?
    false
  end

  def show?
    false
  end

  def create?
    false
  end

  def new?
    false
  end

  def update?
    false
  end

  def edit?
    false
  end

  def destroy?
    false
  end
end
