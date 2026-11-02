import '../../core/utils/api_enum.dart';

enum UserRole with ApiEnum {
  admin('ADMIN'),
  moyensGeneraux('MOYENS_GENERAUX'),
  vigile('VIGILE'),
  delegue('DELEGUE');

  const UserRole(this.apiValue);

  @override
  final String apiValue;

  bool get canManageReclamations => this == admin || this == moyensGeneraux;
}

class AppUser {
  const AppUser({
    required this.id,
    required this.fullName,
    required this.email,
    required this.role,
    this.buildingId,
  });

  final String id;
  final String fullName;
  final String email;
  final UserRole role;
  final String? buildingId;

  /// Bâtiment auquel l'utilisateur est limité (vigile uniquement).
  String? get restrictedBuildingId => role == UserRole.vigile ? buildingId : null;

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
        id: json['id'] as String,
        fullName: json['fullName'] as String,
        email: json['email'] as String,
        role: UserRole.values.byApiValue(json['role'] as String),
        buildingId: json['buildingId'] as String?,
      );
}
