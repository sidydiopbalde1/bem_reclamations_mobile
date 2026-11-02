/// Enum dont la valeur est échangée avec l'API (ex. 'EN_COURS').
mixin ApiEnum on Enum {
  String get apiValue;
}

extension ApiEnumParsing<T extends ApiEnum> on List<T> {
  T byApiValue(String value) => firstWhere(
        (item) => item.apiValue == value,
        orElse: () => throw FormatException('Valeur inconnue : $value'),
      );
}
