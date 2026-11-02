abstract final class Validators {
  static String? required(Object? value) {
    final isEmpty = value == null || (value is String && value.trim().isEmpty);
    return isEmpty ? 'Champ obligatoire' : null;
  }

  static String? email(String? value) {
    return required(value) ?? (value!.contains('@') ? null : 'Email invalide');
  }

  static String? Function(String?) minLength(int length) {
    return (value) => (value?.trim().length ?? 0) < length ? 'Minimum $length caractères' : null;
  }
}
