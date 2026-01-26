# Clear existing data
puts "Clearing existing data..."
Poi.destroy_all
TransitRoute.destroy_all
Stay.destroy_all

puts "Creating US road trip itinerary..."

# US Road Trip - Starting May 22, 2026
# All stays are PLANNED (not yet booked)

# 1. Portland, OR - 2 months
Stay.create!(
  title: "Portland, OR",
  city: "Portland",
  state: "OR",
  country: "USA",
  latitude: 45.5152,
  longitude: -122.6784,
  check_in: Date.new(2026, 5, 22),
  check_out: Date.new(2026, 7, 22),
  notes: "Starting the road trip in the Pacific Northwest! Coffee, food carts, and Powell's Books.",
  image_url: "https://images.unsplash.com/photo-1566093097221-ac2335b09e70?w=800",
  booked: false
)

# 2. Seaside, OR - 2 months
Stay.create!(
  title: "Seaside, OR",
  city: "Seaside",
  state: "OR",
  country: "USA",
  latitude: 45.9932,
  longitude: -123.9226,
  check_in: Date.new(2026, 7, 22),
  check_out: Date.new(2026, 9, 22),
  notes: "Oregon coast beach town. End of the Lewis and Clark Trail.",
  image_url: "https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=800",
  booked: false
)

# 3. San Francisco, CA - 2 months
Stay.create!(
  title: "San Francisco, CA",
  city: "San Francisco",
  state: "CA",
  country: "USA",
  latitude: 37.7749,
  longitude: -122.4194,
  check_in: Date.new(2026, 9, 22),
  check_out: Date.new(2026, 11, 22),
  notes: "Golden Gate, fog, and tech culture. Great food scene.",
  image_url: "https://images.unsplash.com/photo-1501594907352-04cda38ebc29?w=800",
  booked: false
)

# 4. Denver, CO - 2 months
Stay.create!(
  title: "Denver, CO",
  city: "Denver",
  state: "CO",
  country: "USA",
  latitude: 39.7392,
  longitude: -104.9903,
  check_in: Date.new(2026, 11, 22),
  check_out: Date.new(2027, 1, 22),
  notes: "Mile High City! Mountains, breweries, and outdoor adventures.",
  image_url: "https://images.unsplash.com/photo-1546156929-a4c0ac411f47?w=800",
  booked: false
)

# 5. Kansas City, MO - 5 months (longer stay)
Stay.create!(
  title: "Kansas City, MO",
  city: "Kansas City",
  state: "MO",
  country: "USA",
  latitude: 39.0997,
  longitude: -94.5786,
  check_in: Date.new(2027, 1, 22),
  check_out: Date.new(2027, 6, 22),
  notes: "Extended stay in KC! BBQ capital, jazz history, and fountains.",
  image_url: "https://images.unsplash.com/photo-1551522355-5f1c4d8ebb74?w=800",
  booked: false
)

# 6. Chicago, IL - 2 months
Stay.create!(
  title: "Chicago, IL",
  city: "Chicago",
  state: "IL",
  country: "USA",
  latitude: 41.8781,
  longitude: -87.6298,
  check_in: Date.new(2027, 6, 22),
  check_out: Date.new(2027, 8, 22),
  notes: "Deep dish pizza, architecture, and Lake Michigan.",
  image_url: "https://images.unsplash.com/photo-1494522855154-9297ac14b55f?w=800",
  booked: false
)

# 7. NYC, NY - 2 months
Stay.create!(
  title: "NYC, NY",
  city: "NYC",
  state: "NY",
  country: "USA",
  latitude: 40.7128,
  longitude: -74.0060,
  check_in: Date.new(2027, 8, 22),
  check_out: Date.new(2027, 10, 22),
  notes: "The Big Apple! Museums, Broadway, and endless neighborhoods to explore.",
  image_url: "https://images.unsplash.com/photo-1496442226666-8d4d0e62e6e9?w=800",
  booked: false
)

# 8. Cambridge, MA - 2 months
Stay.create!(
  title: "Cambridge, MA",
  city: "Cambridge",
  state: "MA",
  country: "USA",
  latitude: 42.3736,
  longitude: -71.1097,
  check_in: Date.new(2027, 10, 22),
  check_out: Date.new(2027, 12, 22),
  notes: "Harvard, MIT, and historic New England charm.",
  image_url: "https://images.unsplash.com/photo-1580261450046-d0a30080dc9b?w=800",
  booked: false
)

# 9. Portland, ME - 2 months
Stay.create!(
  title: "Portland, ME",
  city: "Portland",
  state: "ME",
  country: "USA",
  latitude: 43.6591,
  longitude: -70.2568,
  check_in: Date.new(2027, 12, 22),
  check_out: Date.new(2028, 2, 22),
  notes: "Ending in Maine! Lobster, lighthouses, and cozy winter vibes.",
  image_url: "https://images.unsplash.com/photo-1605130284535-11dd9eedc58a?w=800",
  booked: false
)

puts "Created #{Stay.count} stays!"
puts ""
puts "Summary:"
puts "  Past stays: #{Stay.past.count}"
puts "  Current stay: #{Stay.current_stay&.title || 'None'}"
puts "  Upcoming stays: #{Stay.upcoming.count}"
puts "  Booked stays: #{Stay.booked.count}"
puts "  Planned stays: #{Stay.planned.count}"
puts "  Gaps to fill: #{Stay.find_gaps.count}"
puts ""
puts "Booking alert: #{Stay.booking_alert ? 'Yes - ' + Stay.booking_alert[:city] : 'None'}"
