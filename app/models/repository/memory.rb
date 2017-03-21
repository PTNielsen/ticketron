class Repository::Memory
  def initialize
    @users     = []
    @concerts  = []
    @tickets   = {}
    @mail      = []
    @playlists = {}
    @auths     = {}
  end

  # ~~ Users ~~
  def user_for_email email, name:
    user = Hashie::Mash.new(email: email, name: name)
    @users.push user
    user
  end

  def user_for_voice_request request
    token = request.request['data']['user']['access_token']
    token = Doorkeeper::AccessToken.by_token token
    return unless token
    @users.find { |u| u.id == token.resource_owner_id }
  end

  def find_auth user:, provider:
    @auths[ [user, provider] ]
  end

  def attach_identity user:, provider:, auth:
    @auths[ [user, provider] ] = auth
  end

  def update_credentials user:, provider:, credentials:
    raise NotImplemented
  end

  # ~~ Venues ~~
  def ensure_venue songkick_id:, name:
    Venue.new(songkick_id: songkick_id, name: name)
  end

  # ~~ Concerts ~~
  def ensure_concert venue:, artists:, songkick_id:, at:
    Concert.new(venue: venue, artists: artists, songkick_id: songkick_id, at: at).tap do |c|
      @concerts.push c
    end
  end

  def upcoming_concerts users:, limit: nil
    now      = Time.now
    concerts = @concerts.select { |c| c.at > now  && users.any? { |u| tickets(c).include? u } }
    limit ? concerts.first(limit) : concerts
  end

  # ~~ Tickets ~~
  def add_tickets user:, concert:, tickets:, method:
    tickets(concert)[user] = { tickets: tickets, method: method }
  end

  def tickets_status user:, concert:
    tickets(concert)[user][:method]
  end

  # ~~ Mail ~~
  def save_mail mail
    @mail.push mail
    mail
  end

  def mail_from user
    @mail.select { |m| m.user == user }
  end

  def attach_concert mail:, concert:
    raise NotImplemented
  end

  # ~~ Spotify ~~
  def spotify_playlist user:
    data = @playlists[user]
    data && Playlist.new(data)
  end

  def update_spotify_playlist user:, user_id: nil, id: nil, url: nil, synced: nil
    @playlists[user] ||= {}
    @playlists[user].merge! \
      user_id: user_id, id: id, url: url, synced_at: synced
  end

  def update_spotify_id artist:, spotify_id:
    raise NotImplemented
  end

  # ~~ Google ~~
  def google_calendar_synced user:
    raise NotImplemented
  end

  private

  def tickets concert
    @tickets[concert] ||= {}
  end
end
