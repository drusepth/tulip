# Clear existing data
puts "Clearing existing data..."
Poi.destroy_all
TransitRoute.destroy_all
Stay.destroy_all

puts "Creating sample stays..."

# Past stay - Tokyo
Stay.create!(
  title: "Modern Apartment in Shibuya",
  stay_type: "airbnb",
  address: "Shibuya",
  city: "Tokyo",
  country: "Japan",
  latitude: 35.6595,
  longitude: 139.7004,
  check_in: Date.current - 60,
  check_out: Date.current - 45,
  price_total_cents: 180000,
  currency: "JPY",
  notes: "Great location near Shibuya crossing. Walking distance to train station.",
  booking_url: "https://airbnb.com/rooms/example1",
  image_url: "https://images.unsplash.com/photo-1540959733332-eab4deabeeaf?w=800"
)

# Past stay - Barcelona
Stay.create!(
  title: "Cozy Studio in Gothic Quarter",
  stay_type: "airbnb",
  address: "Barri Gotic",
  city: "Barcelona",
  country: "Spain",
  latitude: 41.3833,
  longitude: 2.1761,
  check_in: Date.current - 40,
  check_out: Date.current - 25,
  price_total_cents: 95000,
  currency: "EUR",
  notes: "Beautiful historic neighborhood. Great tapas nearby!",
  booking_url: "https://airbnb.com/rooms/example2",
  image_url: "https://images.unsplash.com/photo-1583422409516-2895a77efded?w=800"
)

# Current stay (or recent if needed for testing)
Stay.create!(
  title: "Charming Flat in Montmartre",
  stay_type: "airbnb",
  address: "Montmartre",
  city: "Paris",
  country: "France",
  latitude: 48.8867,
  longitude: 2.3431,
  check_in: Date.current - 5,
  check_out: Date.current + 10,
  price_total_cents: 120000,
  currency: "EUR",
  notes: "Stunning views of Sacre-Coeur. Lots of cafes and artists in the area.",
  booking_url: "https://airbnb.com/rooms/example3",
  image_url: "https://images.unsplash.com/photo-1502602898657-3e91760cbb34?w=800"
)

# Upcoming stay - Lisbon
Stay.create!(
  title: "Sunny Apartment in Alfama",
  stay_type: "airbnb",
  address: "Alfama",
  city: "Lisbon",
  country: "Portugal",
  latitude: 38.7139,
  longitude: -9.1334,
  check_in: Date.current + 15,
  check_out: Date.current + 30,
  price_total_cents: 85000,
  currency: "EUR",
  notes: "Traditional neighborhood with fado music. Near the castle.",
  booking_url: "https://airbnb.com/rooms/example4",
  image_url: "https://images.unsplash.com/photo-1585208798174-6cedd86e019a?w=800"
)

# Future stay - Berlin
Stay.create!(
  title: "Loft in Kreuzberg",
  stay_type: "airbnb",
  address: "Kreuzberg",
  city: "Berlin",
  country: "Germany",
  latitude: 52.4934,
  longitude: 13.4234,
  check_in: Date.current + 45,
  check_out: Date.current + 60,
  price_total_cents: 110000,
  currency: "EUR",
  notes: "Hip neighborhood with great nightlife and food scene.",
  booking_url: "https://airbnb.com/rooms/example5",
  image_url: "https://images.unsplash.com/photo-1560969184-10fe8719e047?w=800"
)

# Future stay - Amsterdam
Stay.create!(
  title: "Canal House Apartment",
  stay_type: "airbnb",
  address: "Jordaan",
  city: "Amsterdam",
  country: "Netherlands",
  latitude: 52.3749,
  longitude: 4.8831,
  check_in: Date.current + 70,
  check_out: Date.current + 85,
  price_total_cents: 140000,
  currency: "EUR",
  notes: "Beautiful views of the canals. Bike-friendly area.",
  booking_url: "https://airbnb.com/rooms/example6",
  image_url: "https://images.unsplash.com/photo-1534351590666-13e3e96b5017?w=800"
)

puts "Created #{Stay.count} stays!"
puts ""
puts "Summary:"
puts "  Past stays: #{Stay.past.count}"
puts "  Current stay: #{Stay.current_stay&.title || 'None'}"
puts "  Upcoming stays: #{Stay.upcoming.count}"
puts "  Gaps to fill: #{Stay.find_gaps.count}"
