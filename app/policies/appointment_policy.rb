class AppointmentPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      return scope.none unless user
      base_scope = scope.where(organization: user.organization)

      if staff?
        base_scope        
      elsif client?
        base_scope.where(id: ::AppointmentGuest.where(user: family_members).pluck(:appointment_id))
      else
        scope.none
      end
    end
  end

  def show?
    return true if staff? && record.organization == user.organization
    return true if client? && record.appointment_guests.any? { |guest| guest.user.in?(family_members) }
    false
  end

  def update
    true
  end
end