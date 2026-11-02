import '../../core/utils/api_enum.dart';

enum ReclamationStatus with ApiEnum {
  ouverte('OUVERTE', 'Ouverte'),
  enCours('EN_COURS', 'En cours'),
  resolue('RESOLUE', 'Résolue'),
  rejetee('REJETEE', 'Rejetée');

  const ReclamationStatus(this.apiValue, this.label);

  @override
  final String apiValue;
  final String label;

  /// Doit rester aligné avec `reclamation-status.policy.ts` côté API (source de vérité).
  List<ReclamationStatus> get nextStatuses => switch (this) {
        ReclamationStatus.ouverte => const [ReclamationStatus.enCours, ReclamationStatus.rejetee],
        ReclamationStatus.enCours => const [ReclamationStatus.resolue, ReclamationStatus.rejetee],
        ReclamationStatus.resolue => const [ReclamationStatus.enCours],
        ReclamationStatus.rejetee => const [],
      };
}

enum ReclamationCategory with ApiEnum {
  climatisation('CLIMATISATION', 'Climatisation'),
  mobilier('MOBILIER', 'Mobilier'),
  eclairage('ECLAIRAGE', 'Éclairage'),
  electricite('ELECTRICITE', 'Électricité'),
  equipement('EQUIPEMENT', 'Équipement'),
  plomberie('PLOMBERIE', 'Plomberie'),
  proprete('PROPRETE', 'Propreté'),
  autre('AUTRE', 'Autre');

  const ReclamationCategory(this.apiValue, this.label);

  @override
  final String apiValue;
  final String label;
}

enum ReclamationPriority with ApiEnum {
  basse('BASSE', 'Basse'),
  normale('NORMALE', 'Normale'),
  haute('HAUTE', 'Haute'),
  urgente('URGENTE', 'Urgente');

  const ReclamationPriority(this.apiValue, this.label);

  @override
  final String apiValue;
  final String label;
}
