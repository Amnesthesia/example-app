# frozen_string_literal: true

module Types::Base
  class ApplicationPolicy < Types::Base::Object

    # Default policy rules from ApplicationPolicy
    default_rules = %i[index show create new update edit destroy]
    default_rules.each do |rule|
      field rule, Boolean, null: true
    end

    default_rules.each do |rule|
      define_method(rule) do
        object.send("#{rule}?") if object.respond_to?("#{rule}?")
      end
    end

    # Additional rules setup defined under the types/policies
    def self.setup_policy_fields(included_rules)
      included_rules.each do |rule|
        field rule, Boolean, null: true
      end

      included_rules.each do |rule|
        define_method(rule) do
          object.send("#{rule}?") if object.respond_to?("#{rule}?")
        end
      end
    end
  end
end