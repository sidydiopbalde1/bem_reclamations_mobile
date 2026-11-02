import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/app_date_format.dart';
import '../../../data/models/reclamation.dart';
import 'reclamation_visuals.dart';
import 'status_chip.dart';

class ReclamationCard extends StatelessWidget {
  const ReclamationCard({
    super.key,
    required this.reclamation,
    required this.onTap,
  });

  final Reclamation reclamation;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final priorityColor = reclamation.priority.color;
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(color: priorityColor, width: 4),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      reclamation.category.icon,
                      size: 16,
                      color: AppColors.secondaryText,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        '${reclamation.reference} · ${reclamation.category.label}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: AppColors.onSurface,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    StatusChip(status: reclamation.status),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  reclamation.location,
                  style: const TextStyle(
                    color: AppColors.secondaryText,
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(
                      Icons.schedule,
                      size: 12,
                      color: AppColors.secondaryText,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        '${AppDateFormat.dateTime(reclamation.createdAt)} · ${reclamation.reportedByName}',
                        style: const TextStyle(
                          color: AppColors.secondaryText,
                          fontSize: 12,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
