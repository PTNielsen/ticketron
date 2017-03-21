class Concert < Dry::Struct
  attribute :artists,     T::Array.member(Artist)
  attribute :venue,       Venue
  attribute :songkick_id, T::String
  attribute :at,          T::Date

  class WithAttendees < ::Concert
    attribute :attendees, T::Array.member(Tickets).optional
  end
end
