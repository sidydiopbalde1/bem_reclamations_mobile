import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/validators.dart';
import '../../../data/models/app_user.dart';
import '../controllers/profile_controller.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Mon profil')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // --- En-tête utilisateur ---
          Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: AppColors.primary,
                child: Text(
                  _initials(controller.user.fullName),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              title: Text(controller.user.fullName),
              subtitle: Text(controller.user.email),
              trailing: _RoleBadge(role: controller.user.role),
            ),
          ),
          const SizedBox(height: 24),

          // --- Section Sécurité ---
          Text(
            'Sécurité',
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: controller.formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: controller.currentPasswordController,
                      obscureText: true,
                      validator: Validators.required,
                      decoration: const InputDecoration(
                        labelText: 'Mot de passe actuel',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: controller.newPasswordController,
                      obscureText: true,
                      validator: Validators.minLength(8),
                      decoration: const InputDecoration(
                        labelText: 'Nouveau mot de passe (8 caractères min.)',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: controller.confirmPasswordController,
                      obscureText: true,
                      validator: (value) {
                        if (value != controller.newPasswordController.text) {
                          return 'Les mots de passe ne correspondent pas';
                        }
                        return null;
                      },
                      decoration: const InputDecoration(
                        labelText: 'Confirmer le nouveau mot de passe',
                      ),
                    ),
                    const SizedBox(height: 16),
                    Obx(
                      () => SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: controller.isSubmitting.value
                              ? null
                              : controller.changePassword,
                          child: controller.isSubmitting.value
                              ? const SizedBox.square(
                                  dimension: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text('Enregistrer'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _initials(String fullName) {
    final parts = fullName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }
}

class _RoleBadge extends StatelessWidget {
  const _RoleBadge({required this.role});

  final UserRole role;

  @override
  Widget build(BuildContext context) {
    const statusEnCours = Color(0xFFE65100);

    final (String label, Color color) = switch (role) {
      UserRole.admin => ('Admin', AppColors.primaryDark),
      UserRole.moyensGeneraux => ('Moyens généraux', statusEnCours),
      UserRole.vigile => ('Vigile', statusEnCours.withValues(alpha: 0.7)),
      UserRole.delegue => ('Délégué', AppColors.secondaryText),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
