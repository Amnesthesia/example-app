class Visibility < EnumerateIt::Base
  associate_values(
    :staff,
    :staff_and_clients
  )
end
