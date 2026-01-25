Geocoder.configure(
  timeout: 5,
  lookup: :nominatim,
  use_https: true,
  http_headers: { "User-Agent" => "Tulip Travel App" }
)
