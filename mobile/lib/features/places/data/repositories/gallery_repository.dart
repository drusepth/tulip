import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/api/api_client.dart';
import '../models/gallery_item_model.dart';

final galleryRepositoryProvider = Provider<GalleryRepository>((ref) {
  return GalleryRepository(ref.watch(apiClientProvider));
});

class GalleryRepository {
  final ApiClient _client;

  GalleryRepository(this._client);

  /// Fetch gallery items for a stay with pagination
  Future<GalleryResponse> getGallery(int stayId, {int page = 1}) async {
    final response = await _client.get('/api/v1/stays/$stayId/gallery', queryParameters: {
      'page': page,
    });

    return GalleryResponse.fromJson(response.data as Map<String, dynamic>);
  }
}
