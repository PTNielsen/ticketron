  Types::TicketEnum = GraphQL::EnumType.define do
    name 'Ticketing Methods'
    description 'Ways of receiving your tickets'

    Tickets::STATUSES.each do |key, method|
      value key.to_s, method.description, value: method
    end
  end
