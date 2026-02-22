# Tulip Mobile App - Planning Guide

This document is a guide for **how to plan** the Tulip mobile app (Android-first, Flutter). It covers what decisions need to be made, what the existing web app does, and the key architectural and design questions that should be resolved before writing any mobile code.

---

## Table of Contents

1. [Existing Web App Inventory](#1-existing-web-app-inventory)
2. [Backend API Strategy](#2-backend-api-strategy)
3. [Feature Scoping & Prioritization](#3-feature-scoping--prioritization)
4. [Architecture Decisions](#4-architecture-decisions)
5. [Design & Theming](#5-design--theming)
6. [Data & Offline Strategy](#6-data--offline-strategy)
7. [Authentication](#7-authentication)
8. [Maps](#8-maps)
9. [External API Dependencies](#9-external-api-dependencies)
10. [Collaboration & Real-Time Features](#10-collaboration--real-time-features)
11. [Push Notifications](#11-push-notifications)
12. [Testing Strategy](#12-testing-strategy)
13. [Release & Distribution](#13-release--distribution)
14. [Open Questions Checklist](#14-open-questions-checklist)

---

## 1. Existing Web App Inventory

Before planning the mobile app, the team needs a shared understanding of every feature the web app provides. Use this inventory as a checklist when deciding what to include in each mobile release.

### Core Models

| Model | Purpose | Key Fields |
|-------|---------|------------|
| **User** | Authentication, profile | email, display_name, password (Devise) |
| **Stay** | Central travel accommodation | title, stay_type (airbnb/hotel/hostel/friend/other), city, state, country, address, lat/lng, check_in, check_out, price_total_cents, currency, status (upcoming/current/past), booked flag, notes, weather_data, destination_images |
| **Place** | Canonical place record (OSM + enrichments) | osm_id, name, category, lat/lng, address, hours, website, phone, cuisine, amenity flags, Foursquare data (rating, price, photo, tip), Wikipedia data (extract, image) |
| **POI** | Stay-specific link to a Place | stay_id, place_id, category, distance_meters, favorite |
| **ViewportPOI** | Grid-cached POI for map browsing | grid_key, category, place_id |
| **TransitRoute** | Cached transit lines near a stay | name, route_type (train/rails/bus/ferry), color, geometry |
| **BucketListItem** | User task/activity for a stay | title, category, notes, address, lat/lng, completed, position, place_id |
| **BucketListItemRating** | Star ratings on bucket list items | rating (1-5), user_id |
| **Comment** | Polymorphic comments (on stays, places, ratings) | body, parent_id (threading), commentable |
| **StayCollaboration** | Shared access to a stay | role (editor), invite_token, invited_email |
| **Notification** | In-app notification system | notification_type, data (JSON), read_at, notifiable |

### Screens & Features

| Web Screen | Description | Key Interactions |
|------------|-------------|------------------|
| **Dashboard** | Home screen: current stay, next stay, upcoming stays grid, wishlist/dream destinations, adventure stats, recent stays, timeline link | Tap into any stay; gap alerts; booking alerts |
| **Stay Detail** | Full stay view with dates, notes, bucket list, POIs, comments, mini-map, weather sidebar, booking status, price, quick actions | Edit, delete, share, leave (collaborator); add to bucket list from POIs |
| **Stay Form** | Create/edit a stay | Title, city, country, state, dates, stay type, booking URL, image URL, price, currency, address, notes, booked toggle |
| **Map View** | Full-screen Leaflet map with side panel | Stay markers, POI overlays (coffee/food/grocery/gym/library/coworking), transit routes (train/light rail/bus/ferry), bucket list pins, stops, floating stay card, Explore panel |
| **Timeline** | Gantt-style visualization + year grid view | Zoom levels (3M/6M/year/all), trip statistics, drag scroll, keyboard navigation, today marker, gap visualization |
| **Things to Do (Gallery)** | Venue grid for a stay with Foursquare photos | Category filters, pagination, add-to-bucket-list |
| **Place Detail** | Individual place page | Photo, rating, price level, Wikipedia extract, details (hours, phone, website), map, comments, directions link, add to bucket list |
| **Trip Highlights** | Completed bucket list items summary | Stats, category filters, item cards with ratings |
| **Destinations** | Featured destination discovery | Grid of curated cities, tap to pre-fill new stay |
| **Weather** | Historical weather forecast for stay dates | Temperature chart, condition grid |
| **Collaborations** | Manage shared access to a stay | Invite by email, manage roles, accept via magic link |
| **Notifications** | Bell icon dropdown with notification list | Mark read, mark all read |
| **Account** | Devise registration/profile/password | Display name, email, password change |

### Existing API Endpoints

These are the JSON endpoints the web app already exposes:

```
GET /api/stays                          → All stays as JSON (for map)
GET /api/stays/:id/pois                 → Fetch/cache POIs for a stay
GET /api/stays/:id/transit_routes       → Fetch/cache transit routes
GET /api/pois/search                    → Search POIs by viewport center
GET /api/bucket_list_items              → Bucket list items as JSON (for map)
GET /stays/:id/weather                  → Fetch/cache weather for a stay
```

### External APIs Used

| Service | Auth | Purpose |
|---------|------|---------|
| Open-Meteo Archive API | None | Historical weather data |
| Overpass API (OpenStreetMap) | None | POI and transit route data |
| Foursquare Places API | API key (credentials) | POI enrichment (ratings, photos, tips) |
| Geocoder (default provider) | Varies | Address → lat/lng conversion |

---

## 2. Backend API Strategy

This is the single most important architectural decision. The mobile app needs a backend API. There are several approaches:

### Option A: Expand the existing Rails JSON API

Add API-specific endpoints to the existing Rails app alongside the web views.

**Decisions needed:**
- Add a versioned API namespace (e.g., `/api/v1/`) or continue with the current flat `/api/` routes?
- What authentication mechanism? (See [Section 7](#7-authentication))
- Do we need full CRUD for all resources, or can we start with a subset?
- Should API responses match the current JSON format, or adopt a standard like JSON:API?
- Rate limiting strategy?

**Pros:** Single codebase, shared business logic, existing models and validations.
**Cons:** Rails app becomes responsible for two clients, API versioning complexity.

### Option B: Dedicated API service

Build a separate API service (Rails API-only, or another framework) that shares the same database.

**Pros:** Clean separation, independent scaling, API-first design.
**Cons:** Code duplication, separate deployment, schema synchronization.

### Option C: Backend-for-Frontend (BFF)

A thin API layer specifically tailored to mobile needs that proxies to the Rails app.

**Pros:** Mobile-optimized payloads, can aggregate multiple backend calls.
**Cons:** Additional infrastructure, another service to maintain.

**Recommended starting point:** Option A. The existing Rails app already has JSON endpoints and the full domain model. Add a proper API namespace, token authentication, and expand the endpoints incrementally.

### API Endpoints to Build

Map out which CRUD operations the mobile app needs for each resource:

```
# Auth
POST   /api/v1/auth/sign_in
POST   /api/v1/auth/sign_up
DELETE /api/v1/auth/sign_out
POST   /api/v1/auth/password/reset

# User
GET    /api/v1/profile
PATCH  /api/v1/profile

# Stays
GET    /api/v1/stays                    → Index (with filters: upcoming, past, wishlist)
GET    /api/v1/stays/:id                → Show (with nested summary data)
POST   /api/v1/stays                    → Create
PATCH  /api/v1/stays/:id                → Update
DELETE /api/v1/stays/:id                → Destroy
GET    /api/v1/stays/:id/weather        → Weather data

# POIs
GET    /api/v1/stays/:id/pois           → List POIs (by category)
POST   /api/v1/stays/:id/pois/fetch     → Trigger POI fetch
PATCH  /api/v1/pois/:id/favorite        → Toggle favorite

# Bucket List
GET    /api/v1/stays/:id/bucket_list_items
POST   /api/v1/stays/:id/bucket_list_items
PATCH  /api/v1/bucket_list_items/:id
DELETE /api/v1/bucket_list_items/:id
PATCH  /api/v1/bucket_list_items/:id/toggle

# Ratings
POST   /api/v1/bucket_list_items/:id/rating
DELETE /api/v1/bucket_list_items/:id/rating

# Comments
GET    /api/v1/stays/:id/comments
POST   /api/v1/stays/:id/comments
PATCH  /api/v1/comments/:id
DELETE /api/v1/comments/:id

# Places
GET    /api/v1/places/:id
GET    /api/v1/places/:id/comments

# Collaborations
GET    /api/v1/stays/:id/collaborations
POST   /api/v1/stays/:id/collaborations
DELETE /api/v1/collaborations/:id

# Transit
GET    /api/v1/stays/:id/transit_routes

# Map
GET    /api/v1/map/stays                → Lightweight stay data for map markers
GET    /api/v1/map/pois/search          → Viewport-based POI search
GET    /api/v1/map/bucket_list_items    → Bucket list items with coordinates

# Notifications
GET    /api/v1/notifications
POST   /api/v1/notifications/:id/read
POST   /api/v1/notifications/read_all

# Destinations
GET    /api/v1/destinations             → Featured destination list
```

---

## 3. Feature Scoping & Prioritization

Not everything needs to ship in v1. Use this framework to decide what goes in each release.

### Suggested Phasing

#### Phase 1: Core MVP
Essential features to make the app useful on its own.

- [ ] Authentication (sign up, sign in, sign out, password reset)
- [ ] Dashboard (current stay, next stay, upcoming stays list)
- [ ] Stay CRUD (create, read, update, delete)
- [ ] Stay detail view (dates, notes, location, booking status, price)
- [ ] Basic map view (stay markers, tap to view details)
- [ ] Bucket list (view, add, toggle complete, delete)
- [ ] Basic notifications

#### Phase 2: Discovery & Exploration
Features that make the app compelling for trip planning.

- [ ] POI discovery (nearby places by category)
- [ ] Place detail view (photos, ratings, hours, website)
- [ ] Things to Do gallery
- [ ] Weather forecast for stays
- [ ] Add POIs/places to bucket list
- [ ] Map POI overlays and search
- [ ] Wishlist/dream destinations

#### Phase 3: Social & Advanced
Collaboration and power features.

- [ ] Stay collaboration (invite, accept, leave)
- [ ] Comments on stays and places
- [ ] Bucket list ratings
- [ ] Transit route overlays on map
- [ ] Timeline view
- [ ] Trip highlights
- [ ] Featured destinations
- [ ] Push notifications

#### Phase 4: Mobile-Native Enhancements
Things the mobile app can do better than the web.

- [ ] Offline mode for current/upcoming stays
- [ ] Camera integration for bucket list items
- [ ] Location-aware features (nearby stay alerts, geo-fencing)
- [ ] Widget for current/next stay on home screen
- [ ] Share stay itinerary as PDF/image
- [ ] Deep linking from invite emails
- [ ] Biometric authentication (fingerprint/face)

### Questions to Answer During Scoping

- What's the minimum feature set that makes someone choose the mobile app over the mobile web?
- Are there features that don't translate to mobile (e.g., the full Gantt timeline)?
- Which features should be mobile-only (camera, widgets, geolocation alerts)?
- What's the target for first internal/beta release?

---

## 4. Architecture Decisions

### State Management

Flutter has several state management options. The choice affects the entire app structure.

| Option | Complexity | Good For |
|--------|-----------|----------|
| **Riverpod** | Medium | Recommended default. Type-safe, testable, good patterns for API data |
| **BLoC/Cubit** | Medium-High | If the team already knows it. Event-driven, good separation |
| **Provider** | Low-Medium | Simpler apps, but Riverpod is its successor |
| **GetX** | Low | Rapid prototyping, but less structured |

**Decision needed:** Which state management approach?

### Project Structure

Decide on code organization up front:

```
lib/
  core/           # Theme, constants, utilities, network client
  features/       # Feature-based modules
    auth/
    stays/
    map/
    bucket_list/
    ...
  models/         # Data classes / entities
  services/       # API clients, local storage
  widgets/        # Shared UI components
```

**Decision needed:** Feature-first vs. layer-first organization?

### Navigation

- **go_router** (declarative, deep linking support) vs. **auto_route** (code generation, type-safe)
- Deep linking is important for collaboration invite links (`/invites/:token`)
- Need to handle authenticated vs. unauthenticated routes

**Decision needed:** Which routing package?

### Networking

- **dio** (feature-rich, interceptors, retry) vs. **http** (simpler, dart core team)
- Need: auth token injection, retry logic, error handling, request/response logging

**Decision needed:** Which HTTP client?

### Local Storage

- **shared_preferences** for simple key-value (auth tokens, settings)
- **drift** or **sqflite** for structured offline data
- **hive** for fast key-value with type support

**Decision needed:** Do we need a local database for offline support, or just token/preference storage for MVP?

---

## 5. Design & Theming

### Translating the Cottagecore Theme

The web app has a strong visual identity that should carry over to mobile. Document these decisions:

#### Color Palette (from web CSS variables)

```
Cream:      #FDF8F3  (background)
Sage:       #B8C9B8  (primary accent)
Sage Dark:  #8FA68F
Sage Light: #D4E4D4
Rose:       #D4A5A5  (secondary accent)
Rose Dark:  #B88888
Rose Light: #F0E0E0
Taupe:      #C9B8A8  (neutral)
Taupe Dark: #A69686
Taupe Light:#E8DFD6
Lavender:   #C8BFD4  (tertiary accent)
Lavender Dk:#9E92B0
Lavender Lt:#E8E4EF
Coral:      #E8B4A0  (alerts/CTA)
Brown:      #5D4E4E  (text)
Brown Light:#8B7E7E
```

#### Typography

```
Headings: Cormorant Garamond (serif)
Body:     Nunito (sans-serif)
```

Both are Google Fonts and available for Flutter via `google_fonts` package.

#### Design Decisions Needed

- [ ] Create a Flutter `ThemeData` that maps the cottagecore palette
- [ ] Design mobile-specific navigation (bottom nav bar like the web? tab bar?)
- [ ] How do `.cozy-card` components translate? (rounded corners, soft shadows, cream backgrounds)
- [ ] Botanical flourishes and decorative SVGs: include on mobile or simplify?
- [ ] Badge system (upcoming/current/past/planned) styling
- [ ] Should we do a full Figma/design pass, or prototype directly in Flutter?
- [ ] Dark mode: the web app doesn't have one. Support it in mobile from the start?

#### Web App Navigation Structure (for reference)

The web app uses a fixed bottom nav bar with:
- **Home** (dashboard)
- **Map** (full-screen map)
- **+ Plan** (new stay, center FAB-style)
- **Timeline** (calendar view)
- **Account** (profile/settings)

This translates naturally to a Flutter `BottomNavigationBar` or `NavigationBar`.

---

## 6. Data & Offline Strategy

### Questions to Answer

- **Which data should be available offline?**
  - Current and upcoming stays (essential for travelers without connectivity)
  - Bucket list for current stay
  - Cached POIs for current stay
  - Weather data for current stay

- **How stale is too stale?** Define cache TTLs:
  - Stays: sync on every app open, cache indefinitely
  - POIs: cache for 7 days (matches web's grid cell cache)
  - Weather: cache for 7 days (matches web's `weather_stale?` check)
  - Places: cache indefinitely (rarely change)

- **Conflict resolution:** If a user edits a stay offline and a collaborator edits it online, how do we merge? Options:
  - Last-write-wins (simplest)
  - Field-level merge
  - Show conflict UI

- **Images:** How to handle stay images and place photos offline?
  - Cache current/upcoming stay images
  - Lazy-load and cache place photos on view

### Sync Architecture

```
┌──────────┐     ┌─────────────┐     ┌──────────┐
│  Flutter  │────▶│  Local DB   │────▶│  Rails   │
│    UI     │◀────│  (drift)    │◀────│  API     │
└──────────┘     └─────────────┘     └──────────┘
                   ▲                       │
                   │   Background sync     │
                   └───────────────────────┘
```

**Decision needed:** Is offline support in scope for v1, or just v2+?

---

## 7. Authentication

The web app uses Devise with session-based authentication. Mobile apps typically use token-based auth.

### Options

#### Option A: JWT tokens via devise-jwt or devise-api
Add a gem to the Rails app that issues JWTs on sign-in.

**Pros:** Well-established pattern, stateless.
**Cons:** Token refresh complexity, revocation is harder.

#### Option B: API tokens (simple)
Generate a random token stored in a `user_tokens` table, sent via `Authorization: Bearer <token>`.

**Pros:** Simple, easy revocation, easy multi-device.
**Cons:** Requires DB lookup on every request.

#### Option C: OAuth2 with Doorkeeper
Full OAuth2 provider in Rails.

**Pros:** Standard protocol, supports refresh tokens, third-party apps.
**Cons:** Heavier setup than needed for a first-party app.

### Additional Auth Decisions

- [ ] Support biometric auth (fingerprint/face unlock)?
- [ ] "Remember me" duration on mobile?
- [ ] How to handle token expiry / refresh in the Flutter app?
- [ ] Secure token storage: `flutter_secure_storage` (uses Keystore on Android)
- [ ] Deep link handling for invite acceptance (`/invites/:token`) — how does this flow on mobile?

---

## 8. Maps

The web app uses Leaflet.js with OpenStreetMap tiles. Flutter has several map options:

### Options

| Package | Tiles | Pros | Cons |
|---------|-------|------|------|
| **flutter_map** | Any (OSM default) | Closest to Leaflet, OSM tiles, free | Less polished than Google Maps |
| **google_maps_flutter** | Google | Polished, good Android integration | API key costs at scale, Google dependency |
| **mapbox_maps_flutter** | Mapbox | Beautiful tiles, custom styles | Pricing at scale |

**Recommended:** `flutter_map` — it uses the same OpenStreetMap tiles as the web app's Leaflet setup, so the map experience will be consistent and there's no API key cost.

### Map Feature Parity Checklist

These are the map features in the web app. Decide which to include and in which phase:

- [ ] Stay markers with custom icons
- [ ] Marker clustering (for many stays)
- [ ] Stay popup cards on marker tap
- [ ] POI overlay by category (coffee, food, grocery, gym, library, coworking)
- [ ] POI markers with category-colored icons
- [ ] Transit route polylines (train, light rail, bus, ferry)
- [ ] Bucket list item pins on map
- [ ] Bus/rail stop markers
- [ ] Viewport-based lazy loading of POIs
- [ ] Grid-based caching (to avoid redundant API calls)
- [ ] Side panel with stay list
- [ ] Floating stay detail card
- [ ] "Explore" panel with layer toggles
- [ ] Mini-map on stay detail page

### Mobile-Specific Map Considerations

- GPS "my location" button
- Directions intent (open Google Maps / transit app for navigation)
- Map performance with many markers on lower-end Android devices
- Gesture handling (pinch zoom, pan, rotate) vs. web mouse interactions

---

## 9. External API Dependencies

The web app fetches data from external APIs server-side and caches it in the database. The mobile app should **not** call these APIs directly — keep them server-side.

### Why Server-Side Only

1. **API keys stay secret** (Foursquare key is in Rails credentials)
2. **Caching is centralized** (one cache, not per-device)
3. **Rate limiting is controlled** (one client, not N mobile devices)
4. **Data enrichment happens once** (Foursquare fuzzy matching, way-stitching for transit)

### Mobile App Approach

The mobile app should call the Rails API, which will internally call Overpass/Foursquare/Open-Meteo as needed and return the cached/enriched data.

```
Mobile App  →  Rails API  →  Overpass / Foursquare / Open-Meteo
                   ↓
              Database cache
```

No changes needed to external API integration — the Rails app already handles caching.

---

## 10. Collaboration & Real-Time Features

The web app supports collaboration via invite links (email with magic token). The mobile app needs to handle:

### Invite Flow on Mobile

```
1. Owner taps "Share" on a stay
2. Enters collaborator email → Rails sends invite email
3. Collaborator receives email with link: https://tulip.app/invites/:token
4. Collaborator taps link on their phone
   a. If app installed → deep link opens app, app calls accept API
   b. If app not installed → opens web, web shows app install prompt
5. Collaborator now sees the stay in their app
```

**Decision needed:**
- [ ] Implement Android App Links for deep linking?
- [ ] How to handle invite acceptance in the app? (dedicated screen vs. auto-accept)
- [ ] Support sharing invite links via native share sheet (WhatsApp, SMS, etc.) in addition to email?

### Real-Time Updates

The web app uses Turbo Streams for real-time updates. The mobile app options:

- **Polling** (simplest): Check for updates every N seconds when viewing a shared stay
- **WebSockets** (ActionCable): Real-time push. Rails already has ActionCable built in
- **Server-Sent Events**: One-way push, simpler than WebSockets
- **Firebase Cloud Messaging**: For background notifications (not real-time data sync)

**Decision needed:** Is real-time sync needed for v1, or is pull-to-refresh sufficient?

---

## 11. Push Notifications

The web app has an in-app notification system. The mobile app should extend this with push notifications.

### Notification Types (from web app)

The existing notification system supports these types (stored in `notification_type` field):
- New comment on your stay
- New collaborator joined your stay
- Bucket list item completed
- Bucket list item rated
- New comment reply

### Implementation Plan

```
Rails App                    Firebase/FCM                  Mobile App
    │                             │                            │
    │──── store notification ────▶│                            │
    │──── send FCM push ────────▶│──── deliver push ─────────▶│
    │                             │                            │
    │◀──── GET /notifications ───────────────────── on tap ───│
```

**Decisions needed:**
- [ ] Use Firebase Cloud Messaging (FCM) for Android push?
- [ ] Store device tokens in a new `device_tokens` table on the Rails side?
- [ ] Which notification types warrant a push vs. just in-app badge?
- [ ] Notification preferences / opt-out controls?

---

## 12. Testing Strategy

### Flutter Testing Layers

| Layer | Tool | What to Test |
|-------|------|-------------|
| **Unit** | `flutter_test` | Models, services, state management logic |
| **Widget** | `flutter_test` | Individual widget rendering and interaction |
| **Integration** | `integration_test` | Full user flows (sign in → create stay → view on map) |
| **API** | `mockito`, `http_mock_adapter` | Mock API responses, test error handling |
| **Golden** | `golden_toolkit` | Screenshot comparison for visual regression |

### Backend API Testing

The Rails app already has tests. For the new API endpoints:
- Controller tests for each API endpoint
- Request specs for full API flow (auth → action → response)
- Continue using webmock for external API stubs

### Decisions Needed

- [ ] Minimum code coverage target?
- [ ] CI/CD pipeline for Flutter (GitHub Actions? Codemagic? Bitrise?)
- [ ] Automated screenshot testing for key screens?
- [ ] End-to-end tests against a staging API?

---

## 13. Release & Distribution

### Android-First Strategy

| Milestone | Channel | Purpose |
|-----------|---------|---------|
| Internal testing | Firebase App Distribution | Team testing, fast iteration |
| Closed beta | Google Play closed testing | Invited users, real-world feedback |
| Open beta | Google Play open testing | Broader audience, Play Store listing |
| Production | Google Play production | Public release |

### Decisions Needed

- [ ] App name and package ID (`com.tulip.app`? `com.tulip.travel`?)
- [ ] Minimum Android SDK version (API 24 / Android 7.0 is a common baseline)
- [ ] Play Store listing assets (screenshots, description, feature graphic)
- [ ] Privacy policy and terms of service (required for Play Store)
- [ ] App signing key management (Play App Signing recommended)
- [ ] CI/CD: auto-build on push to main? Auto-deploy to Firebase App Distribution?
- [ ] When to add iOS? After Android stabilizes, or develop in parallel from the start?
- [ ] Versioning strategy (semver? Build numbers only?)

---

## 14. Open Questions Checklist

Use this as a working checklist during planning sessions. Each question should be answered and documented before development begins.

### Must-Answer Before Starting

- [ ] **API approach:** Expand existing Rails app (recommended) or separate service?
- [ ] **Auth mechanism:** JWT, API tokens, or OAuth2?
- [ ] **Phase 1 feature set:** What's in the MVP? (See Section 3)
- [ ] **State management:** Riverpod, BLoC, or other?
- [ ] **Navigation:** go_router or auto_route?
- [ ] **Map library:** flutter_map, Google Maps, or Mapbox?
- [ ] **Offline support:** In scope for v1 or deferred?
- [ ] **Design process:** Figma-first or prototype in Flutter?

### Should-Answer Before Beta

- [ ] **Push notifications:** FCM setup, which types to push?
- [ ] **Deep linking:** Android App Links for invite flow?
- [ ] **Real-time:** Polling, WebSockets, or neither for v1?
- [ ] **Collaboration UX:** Native share sheet for invites?
- [ ] **Dark mode:** Support from the start?
- [ ] **CI/CD pipeline:** Automated builds and distribution?
- [ ] **Analytics:** Firebase Analytics, Mixpanel, or other?
- [ ] **Crash reporting:** Firebase Crashlytics, Sentry, or other?
- [ ] **Accessibility:** Screen reader support, dynamic text sizing?

### Can-Decide Later

- [ ] iOS timeline and approach
- [ ] Widget for Android home screen
- [ ] Camera integration for bucket list
- [ ] Geofencing and location-based alerts
- [ ] PDF/image export of itineraries
- [ ] Tablet layout optimization

---

## Appendix: Existing Web App Technical Details

### Rails Stack
- Rails 8, Ruby (latest)
- SQLite (development), likely PostgreSQL for production
- Devise for authentication
- Hotwire (Turbo + Stimulus) for frontend interactivity
- Tailwind CSS v4 with custom theme
- Leaflet.js for maps
- Chart.js for weather charts
- Geocoder gem for address → coordinates
- Background jobs for POI fetching

### Existing Navigation (Mobile Web)
The web app already has a mobile bottom nav bar with 5 items:
1. Home (dashboard)
2. Map
3. Plan (new stay — elevated FAB)
4. Timeline
5. Account

This pattern can be directly adopted for the Flutter app's `BottomNavigationBar`.

### Key Background Jobs
- `FetchBrowsablePoisJob` — auto-fetches POIs when a stay is created/updated with coordinates

### Data Serialization Notes
- `pois_cached_categories` on Stay uses YAML serialization (consider JSON for API)
- `weather_data` is stored as JSON text
- `geometry` on TransitRoute is serialized text (array of coordinate arrays)
- `data` on Notification is a JSON column
- `destination_images` on Stay is a JSON column
