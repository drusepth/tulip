import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider for the sync queue
final syncQueueProvider = Provider<SyncQueue>((ref) {
  return SyncQueue();
});

/// Types of sync operations
enum SyncOperationType {
  create,
  update,
  delete,
}

/// A pending sync operation
class SyncOperation {
  final String id;
  final SyncOperationType type;
  final String resource;
  final int? resourceId;
  final Map<String, dynamic>? data;
  final DateTime createdAt;

  SyncOperation({
    required this.id,
    required this.type,
    required this.resource,
    this.resourceId,
    this.data,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'resource': resource,
        'resourceId': resourceId,
        'data': data,
        'createdAt': createdAt.toIso8601String(),
      };

  factory SyncOperation.fromJson(Map<String, dynamic> json) => SyncOperation(
        id: json['id'] as String,
        type: SyncOperationType.values.byName(json['type'] as String),
        resource: json['resource'] as String,
        resourceId: json['resourceId'] as int?,
        data: json['data'] as Map<String, dynamic>?,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}

/// Queue for storing offline mutations to be synced when online
class SyncQueue {
  static const String _queueKey = 'sync_queue';

  /// Add an operation to the sync queue
  Future<void> enqueue(SyncOperation operation) async {
    final operations = await getAll();
    operations.add(operation);
    await _save(operations);
  }

  /// Get all pending operations
  Future<List<SyncOperation>> getAll() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_queueKey);
    if (data == null) return [];

    try {
      final list = json.decode(data) as List<dynamic>;
      return list
          .map((item) => SyncOperation.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Remove an operation from the queue
  Future<void> remove(String operationId) async {
    final operations = await getAll();
    operations.removeWhere((op) => op.id == operationId);
    await _save(operations);
  }

  /// Clear all operations from the queue
  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_queueKey);
  }

  /// Check if there are pending operations
  Future<bool> hasPending() async {
    final operations = await getAll();
    return operations.isNotEmpty;
  }

  /// Get count of pending operations
  Future<int> pendingCount() async {
    final operations = await getAll();
    return operations.length;
  }

  Future<void> _save(List<SyncOperation> operations) async {
    final prefs = await SharedPreferences.getInstance();
    final data = json.encode(operations.map((op) => op.toJson()).toList());
    await prefs.setString(_queueKey, data);
  }

  /// Create a new operation ID
  static String generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }
}
