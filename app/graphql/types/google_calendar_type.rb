Types::GoogleCalendarType = GraphQL::ObjectType.define do
  name 'GoogleCalendar'

  field :lastSynced, types.Float do
    resolve ->(obj, args, ctx) {
      DateTime.parse obj.calendar_synced
    }
  end
end
