# Tulip

A Rails 8 travel planning app for tracking accommodation stays, visualizing them on maps and timelines, and discovering nearby points of interest and transit routes.

## Features

- **Stay Management**: Track your travel accommodations with check-in/check-out dates, locations, pricing, and booking status
- **Interactive Map**: View all your stays on a Leaflet map with cottagecore-styled popups
- **Timeline View**: Gantt-style visualization of your travel schedule with support for overlapping stays
- **POI Discovery**: Find nearby coffee shops, gyms, grocery stores, and other amenities via OpenStreetMap's Overpass API
- **Transit Routes**: View transit lines near your stays with rendered polylines
- **Gap Detection**: Identify unbooked periods in your travel coverage
- **Booking Alerts**: Get reminded when upcoming stays need to be booked

## Tech Stack

- Ruby on Rails 8
- SQLite
- Hotwire (Turbo + Stimulus)
- Tailwind CSS v4
- Leaflet.js for maps
- Geocoder for location lookup

## Setup

```bash
# Install dependencies
bundle install

# Setup database
bin/rails db:setup

# Start development server (Rails + Tailwind watcher)
bin/dev
```

## Commands

```bash
# Development
bin/dev                              # Start dev server with foreman

# Database
bin/rails db:migrate                 # Run migrations
bin/rails db:seed                    # Seed sample data

# Tests
bin/rails test                       # Run all tests
bin/rails test test/models/stay_test.rb  # Run specific test file

# Linting
bin/rubocop                          # Ruby linting
bin/brakeman                         # Security scanning

# Assets
bin/rails tailwindcss:build          # Build CSS
bin/rails tailwindcss:watch          # Watch CSS changes
```

## Architecture

### Core Models

**Stay** - Central model for travel accommodations:
- Location fields (city, state, country, address) with geocoding
- Date tracking (check_in, check_out) with auto-calculated status
- Booking status and pricing
- Has many POIs and TransitRoutes

**POI** - Cached points of interest from Overpass API

**TransitRoute** - Cached transit lines with geometry for map rendering

### Key Services

**OverpassService** - Fetches POI and transit data from OpenStreetMap:
- `fetch_pois(lat:, lng:, category:, radius:)` - nearby amenities
- `fetch_transit_routes(lat:, lng:, route_type:, radius:)` - transit lines

### Frontend

Stimulus controllers for interactivity:
- `map_controller.js` - Main map with stay markers and lazy-loaded overlays
- `timeline_controller.js` - Gantt-style timeline with drag scrolling
- `mini_map_controller.js` - Static maps for stay detail pages
- `tooltip_controller.js` - Hover tooltips

## Design

Cottagecore visual theme with muted pastels:
- Sage (`#B8C9B8`) - Primary/upcoming
- Rose (`#D4A5A5`) - Current/accent
- Taupe (`#C9B8A8`) - Past/neutral
- Lavender (`#C8BFD4`) - Planned
- Cream (`#FDF8F3`) - Background

Custom CSS classes: `.cozy-card`, `.btn-primary`, `.badge-*`, `.cozy-popup`

## API Endpoints

```
GET /api/stays                     - All stays as JSON
GET /api/stays/:id/pois            - POIs for a stay
GET /api/stays/:id/transit_routes  - Transit routes for a stay
GET /api/pois/search               - Search POIs by viewport
```

## License

Private
