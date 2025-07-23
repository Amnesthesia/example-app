class Pundit::User
  attr_accessor :user, :organization

  delegate :staff?,
           :manager?,
           :client?,
           :family_member?,
           :same_family?,
           :with_family_members,
           to: :user

  # Lets us access #family_members and get all Users
  # in the same family visible to the user depending on
  # the User's role
  alias_method :family_members, :with_family_members

  def initialize(user)
    self.user = user
    self.organization = user.organization
  end
end