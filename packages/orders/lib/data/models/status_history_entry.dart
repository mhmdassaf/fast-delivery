import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'status_history_entry.freezed.dart';
part 'status_history_entry.g.dart';

/// A single entry in an order's status timeline.
///
/// Each entry records:
/// - [status]: The `OrderStatus` int value (`0`–`5`) at the time of the change.
/// - [timestamp]: When the status change occurred (Firestore Timestamp).
/// - [actionTakenBy]: UID of the user (or system) who performed the action.
///
/// Stored as an array of maps inside the Firestore `orders/{orderId}` document
/// under the `statusHistory` field.
@freezed
abstract class StatusHistoryEntry with _$StatusHistoryEntry {
  const factory StatusHistoryEntry({
    required int status,
    required DateTime timestamp,
    required String actionTakenBy,
  }) = _StatusHistoryEntry;

  const StatusHistoryEntry._();

  /// Creates from a Firestore map (deserialised from the document array).
  factory StatusHistoryEntry.fromMap(Map<String, dynamic> map) {
    return StatusHistoryEntry(
      status: (map['status'] as num?)?.toInt() ?? 0,
      timestamp: (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      actionTakenBy: map['actionTakenBy'] as String? ?? '',
    );
  }

  /// Serialises to a Firestore-compatible map.
  Map<String, dynamic> toMap() {
    return {
      'status': status,
      'timestamp': Timestamp.fromDate(timestamp),
      'actionTakenBy': actionTakenBy,
    };
  }

  factory StatusHistoryEntry.fromJson(Map<String, dynamic> json) =>
      _$StatusHistoryEntryFromJson(json);
}
