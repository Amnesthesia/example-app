# == Schema Information
#
# Table name: users
#
#  id                 :integer          not null, primary key
#  name               :string
#  encrypted_password :string
#  password_digest    :string
#  role               :string
#  organization_id    :integer
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#
class User < ApplicationRecord
  include AuthToken
  has_secure_password
  belongs_to :organization

  # Appointments created by the user
  has_many :created_appointments, class_name: 'Appointment', foreign_key: :owner_id, inverse_of: :owner, dependent: :destroy

  # Appointments where the user is a guest
  has_many :appointment_guests, inverse_of: :user, dependent: :destroy
  has_many :appointments, through: :appointment_guests

  # FamilyMember links the user to a family and adds metadata
  # about the relationship, and the visibility of the family member
  # to other users in the family. This is used to determine whether
  # other family members can see and manage the user's appointments,
  # e.g in a child-parent relationship.
  has_one :family_member, inverse_of: :user
  has_one :family, through: :family_member

  has_enumeration_for :role, create_helpers: true

  # Get all FamilyMember users for a user
  has_many :family_members, through: :family
  has_many :household, through: :family, source: :users

  # Get all FamilyMembers that are visible to other family members
  has_many :visible_household, through: :family

  # Get all users in the same family as the user
  # This is used to get all users in the same family
  # for a user in a family member relationship
  # e.g. a child-parent relationship.
  has_many :family_users, through: :family_member, source: :users


  scope :staff, -> { where(role: Role::STAFF) }
  scope :clients, -> { where(role: Role::CLIENT) }

  def staff?
    role.to_sym.in?(Role.staff)
  end

  # Get an array of Users that belong to the same family,
  # or fallback to only this User if the User is not in a family
  #
  # @return [ActiveRecord::Relation<User>]
  def with_family_members
    if family.present?
      return household.where(id:).or(household.where(id: visible_household)) if client?
      return household
    end

    ::User.where(id:)
  end

  # Check if another User is in the same family as this User
  #
  # @return [Boolean]
  def family_member?(other)
    return true if self == other
    return false unless other
    return visible_household.exists?(user: other) if client?
    household.exists?(user: other)
  end
  alias_method :same_family?, :family_member?
end
