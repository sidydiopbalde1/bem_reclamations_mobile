import 'reclamation_enums.dart';

class NewReclamation {
  const NewReclamation({
    required this.roomId,
    required this.programId,
    required this.category,
    required this.priority,
    required this.description,
  });

  final String roomId;
  final String programId;
  final ReclamationCategory category;
  final ReclamationPriority priority;
  final String description;

  Map<String, dynamic> toJson() => {
        'roomId': roomId,
        'programId': programId,
        'category': category.apiValue,
        'priority': priority.apiValue,
        'description': description.trim(),
      };
}
