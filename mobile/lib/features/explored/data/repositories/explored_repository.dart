import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/api/endpoints.dart';

final exploredRepositoryProvider = Provider<ExploredRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ExploredRepository(apiClient);
});

class ExploredRepository {
  final ApiClient _apiClient;

  ExploredRepository(this._apiClient);

  /// Fetch scratch-off map data: states with stay counts and details
  Future<ExploredData> getScratchMapData() async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      Endpoints.scratchMap,
    );
    final data = response.data ?? {};
    return ExploredData.fromJson(data);
  }
}

class ExploredData {
  final Map<String, ExploredState> states;
  final int totalVisited;
  final int totalStates;

  ExploredData({
    required this.states,
    required this.totalVisited,
    required this.totalStates,
  });

  factory ExploredData.fromJson(Map<String, dynamic> json) {
    final statesMap = <String, ExploredState>{};
    final statesJson = json['states'] as Map<String, dynamic>? ?? {};
    statesJson.forEach((key, value) {
      statesMap[key] = ExploredState.fromJson(value as Map<String, dynamic>);
    });

    return ExploredData(
      states: statesMap,
      totalVisited: json['total_visited'] as int? ?? 0,
      totalStates: json['total_states'] as int? ?? 50,
    );
  }
}

class ExploredState {
  final int count;
  final List<ExploredStay> stays;

  ExploredState({required this.count, required this.stays});

  factory ExploredState.fromJson(Map<String, dynamic> json) {
    final staysList = (json['stays'] as List<dynamic>? ?? [])
        .map((s) => ExploredStay.fromJson(s as Map<String, dynamic>))
        .toList();
    return ExploredState(
      count: json['count'] as int? ?? 0,
      stays: staysList,
    );
  }
}

class ExploredStay {
  final int id;
  final String title;
  final String? city;
  final String? checkIn;
  final String? checkOut;
  final String? imageUrl;
  final String status;
  final int? durationDays;

  ExploredStay({
    required this.id,
    required this.title,
    this.city,
    this.checkIn,
    this.checkOut,
    this.imageUrl,
    required this.status,
    this.durationDays,
  });

  factory ExploredStay.fromJson(Map<String, dynamic> json) {
    return ExploredStay(
      id: json['id'] as int,
      title: json['title'] as String? ?? '',
      city: json['city'] as String?,
      checkIn: json['check_in'] as String?,
      checkOut: json['check_out'] as String?,
      imageUrl: json['image_url'] as String?,
      status: json['status'] as String? ?? 'past',
      durationDays: json['duration_days'] as int?,
    );
  }
}
