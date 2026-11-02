import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/models/reclamation_enums.dart';

extension ReclamationStatusVisuals on ReclamationStatus {
  Color get color => switch (this) {
        ReclamationStatus.ouverte => AppColors.statusOuverte,
        ReclamationStatus.enCours => AppColors.statusEnCours,
        ReclamationStatus.resolue => AppColors.statusResolue,
        ReclamationStatus.rejetee => AppColors.statusRejetee,
      };

  String get actionLabel => switch (this) {
        ReclamationStatus.ouverte => 'Rouvrir',
        ReclamationStatus.enCours => 'Mettre en cours',
        ReclamationStatus.resolue => 'Marquer résolue',
        ReclamationStatus.rejetee => 'Rejeter',
      };
}

extension ReclamationPriorityVisuals on ReclamationPriority {
  Color get color => switch (this) {
        ReclamationPriority.basse => AppColors.priorityBasse,
        ReclamationPriority.normale => AppColors.priorityNormale,
        ReclamationPriority.haute => AppColors.priorityHaute,
        ReclamationPriority.urgente => AppColors.priorityUrgente,
      };
}

extension ReclamationCategoryVisuals on ReclamationCategory {
  IconData get icon => switch (this) {
        ReclamationCategory.climatisation => Icons.ac_unit,
        ReclamationCategory.mobilier => Icons.chair_outlined,
        ReclamationCategory.eclairage => Icons.lightbulb_outline,
        ReclamationCategory.electricite => Icons.electrical_services,
        ReclamationCategory.equipement => Icons.devices_other,
        ReclamationCategory.plomberie => Icons.plumbing,
        ReclamationCategory.proprete => Icons.cleaning_services_outlined,
        ReclamationCategory.autre => Icons.help_outline,
      };
}
