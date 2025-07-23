class AppointmentStatus < EnumerateIt::Base
  associate_values(
    :draft,
    :scheduled,
    :confirmed,
    :missed,
    :cancelled,
    :rejected,
    :completed
  )
end
