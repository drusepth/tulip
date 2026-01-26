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

### Key Services

**OverpassService** (`app/services/overpass_service.rb`) - fetches POI and transit data from OpenStreetMap's Overpass API:
- `fetch_pois(lat:, lng:, category:, radius:)` - returns nearby amenities
- `fetch_transit_routes(lat:, lng:, route_type:, radius:)` - returns transit lines with stitched geometry
- Handles complex way-stitching for rendering continuous transit route polylines

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

### API Endpoints

```
GET /api/stays                     - All stays as JSON for map
GET /api/stays/:id/pois            - Fetch/cache POIs for a stay
GET /api/stays/:id/transit_routes  - Fetch/cache transit routes for a stay
GET /api/pois/search               - Search POIs by viewport center
```
