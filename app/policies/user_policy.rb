class UserPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      return scope.none unless user
      base_scope = scope.where(organization: user.organization)

      if staff?
        base_scope
      elsif client?
        base_scope.where(id: family_members)
      else
        scope.none
      end
    end
  end

  def show?
    return true if staff? && record.organization == user.organization
    return true if client? && record.in?(family_members)
    false
  end
end