class Endpoints {
  // Auth (devise-api)
  static const String signIn = '/users/tokens/sign_in';
  static const String signUp = '/users/tokens/sign_up';
  static const String refresh = '/users/tokens/refresh';
  static const String revoke = '/users/tokens/revoke';
  static const String tokenInfo = '/users/tokens/info';

  // Profile
  static const String profile = '/api/v1/profile';

  // Stays
  static const String stays = '/api/v1/stays';
  static String stay(int id) => '/api/v1/stays/$id';
  static String stayWeather(int id) => '/api/v1/stays/$id/weather';
  static String stayGallery(int id) => '/api/v1/stays/$id/gallery';

  // POIs
  static String stayPois(int stayId) => '/api/v1/stays/$stayId/pois';
  static String stayPoisFetch(int stayId) => '/api/v1/stays/$stayId/pois/fetch';
  static String stayPoisToggleFavorite(int stayId) =>
      '/api/v1/stays/$stayId/pois/toggle_favorite';

  // Transit Routes
  static String stayTransitRoutes(int stayId) =>
      '/api/v1/stays/$stayId/transit_routes';
  static String stayTransitRoutesFetch(int stayId) =>
      '/api/v1/stays/$stayId/transit_routes/fetch';

  // Bucket List Items
  static String stayBucketListItems(int stayId) =>
      '/api/v1/stays/$stayId/bucket_list_items';
  static String bucketListItem(int id) => '/api/v1/bucket_list_items/$id';
  static String bucketListItemToggle(int id) =>
      '/api/v1/bucket_list_items/$id/toggle';
  static String bucketListItemRate(int id) =>
      '/api/v1/bucket_list_items/$id/rate';

  // Comments
  static String stayComments(int stayId) => '/api/v1/stays/$stayId/comments';
  static String comment(int id) => '/api/v1/comments/$id';

  // Collaborations
  static String stayCollaborations(int stayId) =>
      '/api/v1/stays/$stayId/collaborations';
  static String stayCollaboration(int stayId, int id) =>
      '/api/v1/stays/$stayId/collaborations/$id';
  static String stayCollaborationsLeave(int stayId) =>
      '/api/v1/stays/$stayId/collaborations/leave';

  // Notifications
  static const String notifications = '/api/v1/notifications';
  static String notificationRead(int id) => '/api/v1/notifications/$id/read';
  static const String notificationsMarkAllRead =
      '/api/v1/notifications/mark_all_read';

  // Map
  static const String mapStays = '/api/v1/map/stays';
  static const String mapPoisSearch = '/api/v1/map/pois/search';
  static const String mapBucketListItems = '/api/v1/map/bucket_list_items';

  // Places
  static String place(int id) => '/api/v1/places/$id';
  static String placeComments(int placeId) =>
      '/api/v1/places/$placeId/comments';

  // Invites
  static String acceptInvite(String token) => '/api/v1/invites/$token/accept';

  // Destinations
  static const String destinations = '/api/v1/destinations';
}
