# frozen_string_literal: true

class FeaturedDestination
  DESTINATIONS = [
    {
      city: "Lisbon",
      country: "Portugal",
      tagline: "Sun-soaked hills & pastel tiles",
      image_url: "https://images.unsplash.com/photo-1585208798174-6cedd86e019a?w=800&q=80"
    },
    {
      city: "Kyoto",
      country: "Japan",
      tagline: "Ancient temples & zen gardens",
      image_url: "https://images.unsplash.com/photo-1493976040374-85c8e12f0c0e?w=800&q=80"
    },
    {
      city: "Copenhagen",
      country: "Denmark",
      tagline: "Hygge & colorful harbors",
      image_url: "https://images.unsplash.com/photo-1513622470522-26c3c8a854bc?w=800&q=80"
    },
    {
      city: "Medellín",
      country: "Colombia",
      tagline: "Eternal spring & mountain views",
      image_url: "https://images.unsplash.com/photo-1568632234157-ce7aecd03d0d?w=800&q=80"
    },
    {
      city: "Porto",
      country: "Portugal",
      tagline: "Wine cellars & riverside charm",
      image_url: "https://images.unsplash.com/photo-1555881400-74d7acaacd8b?w=800&q=80"
    },
    {
      city: "Chiang Mai",
      country: "Thailand",
      tagline: "Temples, night markets & mountains",
      image_url: "https://images.unsplash.com/photo-1528181304800-259b08848526?w=800&q=80"
    },
    {
      city: "Cape Town",
      country: "South Africa",
      tagline: "Where mountains meet the sea",
      image_url: "https://images.unsplash.com/photo-1580060839134-75a5edca2e99?w=800&q=80"
    },
    {
      city: "Barcelona",
      country: "Spain",
      tagline: "Gaudí dreams & beach vibes",
      image_url: "https://images.unsplash.com/photo-1583422409516-2895a77efded?w=800&q=80"
    },
    {
      city: "Marrakech",
      country: "Morocco",
      tagline: "Spices, souks & sunsets",
      image_url: "https://images.unsplash.com/photo-1597212618440-806262de4f6b?w=800&q=80"
    },
    {
      city: "Reykjavik",
      country: "Iceland",
      tagline: "Northern lights & volcanic wonders",
      image_url: "https://images.unsplash.com/photo-1504829857797-ddff29c27927?w=800&q=80"
    },
    {
      city: "Buenos Aires",
      country: "Argentina",
      tagline: "Tango, steak & vibrant neighborhoods",
      image_url: "https://images.unsplash.com/photo-1612294037637-ec328d0e075e?w=800&q=80"
    },
    {
      city: "Prague",
      country: "Czech Republic",
      tagline: "Gothic spires & cobblestone charm",
      image_url: "https://images.unsplash.com/photo-1519677100203-a0e668c92439?w=800&q=80"
    }
  ].freeze

  attr_reader :city, :country, :tagline, :image_url

  def initialize(attrs)
    @city = attrs[:city]
    @country = attrs[:country]
    @tagline = attrs[:tagline]
    @image_url = attrs[:image_url]
  end

  def self.all
    DESTINATIONS.map { |attrs| new(attrs) }
  end

  def self.random
    new(DESTINATIONS.sample)
  end

  def self.of_the_day
    # Rotate daily based on day of year
    index = Date.current.yday % DESTINATIONS.length
    new(DESTINATIONS[index])
  end

  def location
    "#{city}, #{country}"
  end
end
