import 'dart:async';
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import '../local/database.dart';

enum SyncState { offline, syncing, synced, error }

class SyncManager {
  final AppDatabase _db;
  final Dio _dio;
  final String serverBaseUrl;

  StreamSubscription<ConnectivityResult>? _connectivitySub;
  bool _isSyncing = false;
  SyncState _state = SyncState.offline;

  SyncManager(this._db, this._dio,
      {this.serverBaseUrl = 'http://localhost:3000/api/v1'}) {
    _initConnectivityListener();
  }

  SyncState get state => _state;

  void _initConnectivityListener() {
    _connectivitySub = Connectivity().onConnectivityChanged.listen((result) {
      if (result != ConnectivityResult.none) {
        _state = SyncState.syncing;
        processPendingQueue();
      } else {
        _state = SyncState.offline;
      }
    });
  }

  /// Uploads pending delivery events from SQLite sync_queue in batch
  Future<void> processPendingQueue() async {
    if (_isSyncing) return;
    _isSyncing = true;

    try {
      final pendingItems = await _db.getPendingSyncItems();
      if (pendingItems.isEmpty) {
        _state = SyncState.synced;
        _isSyncing = false;
        return;
      }

      // Group pending events by matchId
      final Map<String, List<SyncQueueTableData>> matchBatches = {};
      for (final item in pendingItems) {
        matchBatches.putIfAbsent(item.matchId, () => []).add(item);
      }

      for (final entry in matchBatches.entries) {
        final matchId = entry.key;
        final items = entry.value;

        final payloads = items.map((i) => jsonDecode(i.payloadJson)).toList();

        try {
          final response = await _dio.post(
            '$serverBaseUrl/matches/$matchId/events/sync',
            data: {
              'deviceId': items.first.payloadJson.contains('scorerDeviceId')
                  ? jsonDecode(items.first.payloadJson)['scorerDeviceId']
                  : 'local_device',
              'events': payloads,
            },
            options: Options(
              sendTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 10),
            ),
          );

          if (response.statusCode == 200 || response.statusCode == 201) {
            // Mark items as synced
            for (final item in items) {
              await _db.updateSyncItemStatus(item.id, 'synced');
            }
          }
        } on DioException catch (e) {
          for (final item in items) {
            await _db.updateSyncItemStatus(
              item.id,
              'failed',
              error: e.message,
            );
          }
        }
      }

      _state = SyncState.synced;
    } catch (e) {
      _state = SyncState.error;
    } finally {
      _isSyncing = false;
    }
  }

  void dispose() {
    _connectivitySub?.cancel();
  }
}
