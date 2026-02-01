# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

Tulip is a Rails 8 travel planning app for tracking accommodation stays, visualizing them on maps and timelines, and discovering nearby points of interest and transit routes. It uses a "cottagecore" visual theme with muted pastels (sage, rose, taupe, lavender).

## Commands

```bash
# Development server (runs Rails + Tailwind watcher via foreman)
bin/dev

# Database
bin/rails db:migrate
bin/rails db:seed

# Tests
bin/rails test                           # Run all tests
bin/rails test test/models/stay_test.rb  # Run single test file

# Linting
bin/rubocop
bin/brakeman

# Tailwind CSS (usually run via bin/dev)
bin/rails tailwindcss:build
bin/rails tailwindcss:watch
```

## Architecture

### Core Domain Model

**Stay** is the central model representing a travel accommodation booking:
- Has location fields (city, state, country, address) that are geocoded to lat/lng
- Tracks dates (check_in, check_out), booking status, and pricing
- Auto-calculates status (upcoming/current/past) based on dates
- Has many POIs and TransitRoutes for nearby amenities

**POI** (Point of Interest) - cached results from Overpass API for amenities near stays (coffee shops, gyms, grocery stores, etc.)

**ViewportPOI** - grid-based cached POIs for map exploration (not tied to specific stays)

**TransitRoute** - cached transit lines near stays with serialized geometry for map rendering

**BucketListItem** - user-created tasks/activities associated with a stay (e.g., restaurants to try, attractions to visit)

### Key Services

**OverpassService** (`app/services/overpass_service.rb`) - fetches POI and transit data from OpenStreetMap's Overpass API:
- `fetch_pois(lat:, lng:, category:, radius:)` - returns nearby amenities
- `fetch_transit_routes(lat:, lng:, route_type:, radius:)` - returns transit lines with stitched geometry
- Handles complex way-stitching for rendering continuous transit route polylines

**WeatherService** (`app/services/weather_service.rb`) - fetches historical weather data from Open-Meteo Archive API:
- `fetch_historical_weather(lat:, lng:, start_date:, end_date:)` - returns temperature ranges and conditions
- Looks back up to 5 years to find historical data for future trip dates
- Weather data is cached on Stay model (`weather_data`, `weather_fetched_at`)

**FoursquareService** (`app/services/foursquare_service.rb`) - enriches POIs with Foursquare data:
- `enrich_poi(poi)` - adds ratings, prices, photos, and tips to a POI
- Uses Levenshtein distance for fuzzy name matching
- Requires `foursquare_service_token` in Rails credentials

### Frontend Architecture

Uses Hotwire (Turbo + Stimulus) with Leaflet maps:

**map_controller.js** - Main map view with:
- Stay markers with cottagecore-styled popups
- Lazy-loaded POI and transit overlays (fetched on viewport change)
- Grid-based caching to avoid redundant API calls

**timeline_controller.js** - Gantt-style timeline visualization of stays

**mini_map_controller.js** - Small static map for stay detail pages

### Styling

- Tailwind CSS v4 with custom cottagecore theme in `app/assets/tailwind/application.css`
- Custom CSS properties for colors: `--color-sage`, `--color-rose`, `--color-taupe`, `--color-lavender`, `--color-cream`
- Custom component classes: `.cozy-card`, `.btn-primary`, `.badge-*`, `.cozy-popup`
- **IMPORTANT**: Do NOT use Tailwind opacity shorthand like `bg-white/30` or `text-black/50` - this syntax is not supported. Use `opacity-30` on the element instead, or define custom colors with opacity in the CSS file.

### API Endpoints

```
GET /api/stays                     - All stays as JSON for map
GET /api/stays/:id/pois            - Fetch/cache POIs for a stay
GET /api/stays/:id/transit_routes  - Fetch/cache transit routes for a stay
GET /api/pois/search               - Search POIs by viewport center
GET /stays/:id/weather             - Fetch/cache weather forecast for a stay
```

### External APIs

The app integrates with several external APIs (use webmock for stubbing in tests):
- **Open-Meteo Archive API** - historical weather data (no API key required)
- **Overpass API** - OpenStreetMap POI and transit data (no API key required)
- **Foursquare Places API** - POI enrichment (requires `foursquare_service_token` in credentials)
- **Geocoder** - address to lat/lng conversion (uses default provider)
