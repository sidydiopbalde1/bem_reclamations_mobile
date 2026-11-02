import '../../core/utils/api_enum.dart';
import 'reclamation_enums.dart';

class Reclamation {
  const Reclamation({
    required this.id,
    required this.number,
    required this.category,
    required this.priority,
    required this.status,
    required this.description,
    required this.roomNumber,
    required this.buildingName,
    required this.programName,
    required this.reportedByName,
    required this.createdAt,
    this.resolvedAt,
    this.events = const [],
  });

  final String id;
  final int number;
  final ReclamationCategory category;
  final ReclamationPriority priority;
  final ReclamationStatus status;
  final String description;
  final String roomNumber;
  final String buildingName;
  final String programName;
  final String reportedByName;
  final DateTime createdAt;
  final DateTime? resolvedAt;
  final List<ReclamationEvent> events;

  String get reference => 'REC-${number.toString().padLeft(5, '0')}';

  String get location => 'Salle $roomNumber · $buildingName';

  factory Reclamation.fromJson(Map<String, dynamic> json) {
    final room = json['room'] as Map<String, dynamic>;
    final events = json['events'] as List<dynamic>? ?? const [];

    return Reclamation(
      id: json['id'] as String,
      number: json['number'] as int,
      category: ReclamationCategory.values.byApiValue(json['category'] as String),
      priority: ReclamationPriority.values.byApiValue(json['priority'] as String),
      status: ReclamationStatus.values.byApiValue(json['status'] as String),
      description: json['description'] as String,
      roomNumber: room['number'] as String,
      buildingName: (room['building'] as Map<String, dynamic>)['name'] as String,
      programName: (json['program'] as Map<String, dynamic>)['name'] as String,
      reportedByName: (json['reportedBy'] as Map<String, dynamic>)['fullName'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      resolvedAt: _parseOptionalDate(json['resolvedAt']),
      events: events.cast<Map<String, dynamic>>().map(ReclamationEvent.fromJson).toList(),
    );
  }
}

class ReclamationEvent {
  const ReclamationEvent({
    required this.toStatus,
    required this.authorName,
    required this.createdAt,
    this.fromStatus,
    this.comment,
  });

  final ReclamationStatus? fromStatus;
  final ReclamationStatus toStatus;
  final String authorName;
  final DateTime createdAt;
  final String? comment;

  bool get isCreation => fromStatus == null;

  factory ReclamationEvent.fromJson(Map<String, dynamic> json) => ReclamationEvent(
        fromStatus: switch (json['fromStatus']) {
          final String value => ReclamationStatus.values.byApiValue(value),
          _ => null,
        },
        toStatus: ReclamationStatus.values.byApiValue(json['toStatus'] as String),
        authorName: (json['author'] as Map<String, dynamic>)['fullName'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
        comment: json['comment'] as String?,
      );
}

DateTime? _parseOptionalDate(Object? value) => value is String ? DateTime.parse(value) : null;
