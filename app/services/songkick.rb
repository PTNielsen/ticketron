class Songkick < Gestalt[:remote, :repository]
  ConcertNotFound = Class.new StandardError

  def self.build repository: nil
    new \
      remote:     Songkickr::Remote.new(Figaro.env.songkick_api_key!),
      repository: repository || Repository.new
  end

  def find_venue name
    result = remote.venue_search(query: name).results.first
    repository.ensure_venue \
      songkick_id: result.id,
      name:        result.display_name
  end

  def find_concert venue:, artists:, date:
    artist   = remote.artist_search(artists.first).results.first
    date_str = date.strftime '%Y-%m-%d'

    event = remote.
      artist_events(artist.id, min_date: date_str, max_date: date_str).
      results.first

    unless event
      raise Songkick::ConcertNotFound
    end

    repository.ensure_concert \
      venue: {
        songkick_id: event.venue.id,
        name:        event.venue.display_name
      },
      artists: event.performances.map { |a|
        {
          songkick_id: a.id,
          name:        a.display_name
        }
      },
      songkick_id: event.id,
      at:          event.start
  end
end
