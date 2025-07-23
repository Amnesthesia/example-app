class Role < EnumerateIt::Base
  associate_values(
    :admin,
    :manager,
    :employee,
    :client
  )

  def self.staff
    %i[admin manager employee]
  end
end
