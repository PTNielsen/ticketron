Types::ViewerType = GraphQL::ObjectType.define do
  name 'Viewer'

  field :concerts, types[Types::ConcertType] do
    resolve ->(obj, args, ctx) {
      ctx[:container].repository.upcoming_concerts users: [obj]
    }
  end

  field :mail, types[Types::MailType] do
    resolve ->(obj, args, ctx) {
      ctx[:container].repository.mail_from obj
    }
  end

  field :spotify, Types::SpotifyType do
    resolve ->(obj, args, ctx) {
      obj.meta.spotify
    }
  end

  field :googleCalendar, Types::GoogleCalendarType do
    resolve ->(obj, args, ctx) {
      obj.meta.google
    }
  end

  field :friends, types[Types::FriendType]

  # - search (songkick) for concerts?
end
