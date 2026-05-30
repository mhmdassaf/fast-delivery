// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'status_history_entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_StatusHistoryEntry _$StatusHistoryEntryFromJson(Map<String, dynamic> json) =>
    _StatusHistoryEntry(
      status: (json['status'] as num).toInt(),
      timestamp: DateTime.parse(json['timestamp'] as String),
      actionTakenBy: json['actionTakenBy'] as String,
    );

Map<String, dynamic> _$StatusHistoryEntryToJson(_StatusHistoryEntry instance) =>
    <String, dynamic>{
      'status': instance.status,
      'timestamp': instance.timestamp.toIso8601String(),
      'actionTakenBy': instance.actionTakenBy,
    };
