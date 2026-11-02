import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/utils/validators.dart';
import '../../../data/models/app_user.dart';
import '../../../data/models/referentials.dart';
import '../controllers/admin_controller.dart';
import '../widgets/entity_form_dialog.dart';

extension UserRoleLabel on UserRole {
  String get label => switch (this) {
        UserRole.admin => 'Administrateur',
        UserRole.moyensGeneraux => 'Moyens généraux',
        UserRole.vigile => 'Vigile',
        UserRole.delegue => 'Délégué',
      };
}

class AdminView extends GetView<AdminController> {
  const AdminView({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Administration'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Bâtiments'),
              Tab(text: 'Programmes'),
              Tab(text: 'Comptes'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _BuildingsTab(),
            _ProgramsTab(),
            _UsersTab(),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Edit / Delete buttons
// ---------------------------------------------------------------------------

class _EditDeleteButtons extends StatelessWidget {
  const _EditDeleteButtons({required this.onEdit, required this.onDelete});

  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.edit_outlined),
          onPressed: onEdit,
        ),
        IconButton(
          icon: const Icon(Icons.delete_outline),
          color: Colors.red,
          onPressed: onDelete,
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Confirm delete dialog helper
// ---------------------------------------------------------------------------

Future<bool> _confirmDelete(String message) async {
  final result = await Get.dialog<bool>(
    AlertDialog(
      title: const Text('Confirmer la suppression'),
      content: Text(message),
      actions: [
        TextButton(onPressed: () => Get.back(result: false), child: const Text('Annuler')),
        FilledButton(
          onPressed: () => Get.back(result: true),
          style: FilledButton.styleFrom(backgroundColor: Colors.red),
          child: const Text('Supprimer'),
        ),
      ],
    ),
  );
  return result ?? false;
}

// ---------------------------------------------------------------------------
// Buildings Tab
// ---------------------------------------------------------------------------

class _BuildingsTab extends GetView<AdminController> {
  const _BuildingsTab();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final buildings = controller.buildings;
      return Stack(
        children: [
          ListView.builder(
            padding: const EdgeInsets.only(bottom: 80),
            itemCount: buildings.length + 1,
            itemBuilder: (context, index) {
              if (index == buildings.length) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final name = await EntityFormDialog.show(title: 'Nouveau bâtiment');
                      if (name != null && name.isNotEmpty) {
                        controller.addBuilding(name);
                      }
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Ajouter un bâtiment'),
                  ),
                );
              }
              return _BuildingTile(building: buildings[index]);
            },
          ),
          if (controller.isLoadingRef.value)
            const Center(child: CircularProgressIndicator()),
        ],
      );
    });
  }
}

class _BuildingTile extends GetView<AdminController> {
  const _BuildingTile({required this.building});

  final Building building;

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text(building.name),
      trailing: _EditDeleteButtons(
        onEdit: () async {
          final name = await EntityFormDialog.show(
            title: 'Modifier le bâtiment',
            initialValue: building.name,
          );
          if (name != null && name.isNotEmpty) {
            controller.editBuilding(building, name);
          }
        },
        onDelete: () async {
          final confirmed = await _confirmDelete('Supprimer « ${building.name} » ?');
          if (confirmed) controller.deleteBuilding(building);
        },
      ),
      children: [
        ...building.rooms.map((room) => ListTile(
              contentPadding: const EdgeInsets.only(left: 32, right: 8),
              title: Text('Salle ${room.number}'),
              trailing: _EditDeleteButtons(
                onEdit: () async {
                  final number = await EntityFormDialog.show(
                    title: 'Modifier la salle',
                    initialValue: room.number,
                  );
                  if (number != null && number.isNotEmpty) {
                    controller.editRoom(room, number);
                  }
                },
                onDelete: () async {
                  final confirmed =
                      await _confirmDelete('Supprimer la salle « ${room.number} » ?');
                  if (confirmed) controller.deleteRoom(room);
                },
              ),
            ),),
        ListTile(
          contentPadding: const EdgeInsets.only(left: 32, right: 16),
          leading: const Icon(Icons.add),
          title: const Text('Ajouter une salle'),
          onTap: () async {
            final number = await EntityFormDialog.show(title: 'Nouvelle salle');
            if (number != null && number.isNotEmpty) {
              controller.addRoom(building, number);
            }
          },
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Programs Tab
// ---------------------------------------------------------------------------

class _ProgramsTab extends GetView<AdminController> {
  const _ProgramsTab();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final programs = controller.programs;
      return Stack(
        children: [
          ListView.builder(
            padding: const EdgeInsets.only(bottom: 80),
            itemCount: programs.length + 1,
            itemBuilder: (context, index) {
              if (index == programs.length) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final name = await EntityFormDialog.show(title: 'Nouveau programme');
                      if (name != null && name.isNotEmpty) {
                        controller.addProgram(name);
                      }
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Ajouter un programme'),
                  ),
                );
              }
              final program = programs[index];
              return ListTile(
                title: Text(program.name),
                trailing: _EditDeleteButtons(
                  onEdit: () async {
                    final name = await EntityFormDialog.show(
                      title: 'Modifier le programme',
                      initialValue: program.name,
                    );
                    if (name != null && name.isNotEmpty) {
                      controller.editProgram(program, name);
                    }
                  },
                  onDelete: () async {
                    final confirmed = await _confirmDelete('Supprimer « ${program.name} » ?');
                    if (confirmed) controller.deleteProgram(program);
                  },
                ),
              );
            },
          ),
          if (controller.isLoadingRef.value)
            const Center(child: CircularProgressIndicator()),
        ],
      );
    });
  }
}

// ---------------------------------------------------------------------------
// Users Tab
// ---------------------------------------------------------------------------

class _UsersTab extends GetView<AdminController> {
  const _UsersTab();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final users = controller.users;
      return Stack(
        children: [
          ListView.builder(
            padding: const EdgeInsets.only(bottom: 88),
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              final initials = user.fullName
                  .split(' ')
                  .where((w) => w.isNotEmpty)
                  .take(2)
                  .map((w) => w[0].toUpperCase())
                  .join();
              return ListTile(
                leading: CircleAvatar(child: Text(initials)),
                title: Text(user.fullName),
                subtitle: Text(user.email),
                trailing: PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {
                      _showEditRoleDialog(context, user);
                    } else if (value == 'deactivate') {
                      _showDeactivateDialog(user);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'edit', child: Text('Modifier le rôle')),
                    const PopupMenuItem(value: 'deactivate', child: Text('Désactiver')),
                  ],
                ),
              );
            },
          ),
          if (controller.isLoadingUsers.value)
            const Center(child: CircularProgressIndicator()),
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton.extended(
              onPressed: () => _showCreateUserDialog(context),
              icon: const Icon(Icons.person_add_outlined),
              label: const Text('Nouveau compte'),
            ),
          ),
        ],
      );
    });
  }

  void _showEditRoleDialog(BuildContext context, AppUser user) {
    var role = user.role;
    var buildingId = user.buildingId;

    Get.dialog(
      StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Modifier le rôle de ${user.fullName}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<UserRole>(
                value: role,
                decoration: const InputDecoration(labelText: 'Rôle'),
                items: UserRole.values
                    .map((r) => DropdownMenuItem(value: r, child: Text(r.label)))
                    .toList(),
                onChanged: (r) {
                  if (r != null) {
                    setState(() {
                      role = r;
                      if (r != UserRole.vigile) buildingId = null;
                    });
                  }
                },
              ),
              if (role == UserRole.vigile) ...[
                const SizedBox(height: 12),
                Obx(() {
                  final buildings = controller.buildings;
                  final safeValue = buildings.any((b) => b.id == buildingId) ? buildingId : null;
                  return DropdownButtonFormField<String>(
                    value: safeValue,
                    decoration: const InputDecoration(labelText: 'Bâtiment'),
                    items: buildings
                        .map((b) => DropdownMenuItem(value: b.id, child: Text(b.name)))
                        .toList(),
                    onChanged: (id) => setState(() => buildingId = id),
                  );
                }),
              ],
            ],
          ),
          actions: [
            TextButton(onPressed: Get.back, child: const Text('Annuler')),
            FilledButton(
              onPressed: () {
                Get.back();
                controller.updateUserRole(user, role, buildingId: buildingId);
              },
              child: const Text('Confirmer'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeactivateDialog(AppUser user) {
    Get.dialog(
      AlertDialog(
        title: const Text('Désactiver le compte'),
        content: Text('Désactiver le compte de « ${user.fullName} » ?'),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('Annuler')),
          FilledButton(
            onPressed: () {
              Get.back();
              controller.deactivateUser(user);
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Désactiver'),
          ),
        ],
      ),
    );
  }

  void _showCreateUserDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final fullNameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final passwordCtrl = TextEditingController();
    var role = UserRole.delegue;
    String? buildingId;

    Get.dialog(
      StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Nouveau compte'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: fullNameCtrl,
                    decoration: const InputDecoration(labelText: 'Nom complet'),
                    validator: Validators.required,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: emailCtrl,
                    decoration: const InputDecoration(labelText: 'Email'),
                    keyboardType: TextInputType.emailAddress,
                    validator: Validators.email,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: passwordCtrl,
                    decoration: const InputDecoration(labelText: 'Mot de passe'),
                    obscureText: true,
                    validator: Validators.minLength(6),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<UserRole>(
                    value: role,
                    decoration: const InputDecoration(labelText: 'Rôle'),
                    items: UserRole.values
                        .map((r) => DropdownMenuItem(value: r, child: Text(r.label)))
                        .toList(),
                    onChanged: (r) {
                      if (r != null) {
                        setState(() {
                          role = r;
                          if (r != UserRole.vigile) buildingId = null;
                        });
                      }
                    },
                    validator: Validators.required,
                  ),
                  if (role == UserRole.vigile) ...[
                    const SizedBox(height: 12),
                    Obx(() {
                      final buildings = controller.buildings;
                      final safeValue = buildings.any((b) => b.id == buildingId) ? buildingId : null;
                      return DropdownButtonFormField<String>(
                        value: safeValue,
                        decoration: const InputDecoration(labelText: 'Bâtiment'),
                        items: buildings
                            .map((b) => DropdownMenuItem(value: b.id, child: Text(b.name)))
                            .toList(),
                        onChanged: (id) => setState(() => buildingId = id),
                      );
                    }),
                  ],
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                fullNameCtrl.dispose();
                emailCtrl.dispose();
                passwordCtrl.dispose();
                Get.back();
              },
              child: const Text('Annuler'),
            ),
            FilledButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  final fullName = fullNameCtrl.text.trim();
                  final email = emailCtrl.text.trim();
                  final password = passwordCtrl.text;
                  fullNameCtrl.dispose();
                  emailCtrl.dispose();
                  passwordCtrl.dispose();
                  Get.back();
                  controller.createUser(
                    fullName: fullName,
                    email: email,
                    password: password,
                    role: role,
                    buildingId: buildingId,
                  );
                }
              },
              child: const Text('Créer'),
            ),
          ],
        ),
      ),
    );
  }
}

