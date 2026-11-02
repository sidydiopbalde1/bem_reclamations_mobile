import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/utils/app_snackbar.dart';
import '../../../data/models/app_user.dart';
import '../../../data/models/referentials.dart';
import '../../../data/repositories/admin_repository.dart';
import '../../../data/repositories/referentials_repository.dart';

class AdminController extends GetxController {
  AdminController(this._refRepo, this._adminRepo);

  final ReferentialsRepository _refRepo;
  final AdminRepository _adminRepo;

  // Referentials state
  final buildings = <Building>[].obs;
  final programs = <Program>[].obs;
  final isLoadingRef = false.obs;

  // Users state
  final users = <AppUser>[].obs;
  final isLoadingUsers = false.obs;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadReferentials();
      loadUsers();
    });
  }

  // --- REFERENTIALS ---

  Future<void> loadReferentials() async {
    isLoadingRef.value = true;
    try {
      final results = await Future.wait([
        _refRepo.fetchBuildings(),
        _refRepo.fetchPrograms(),
      ]);
      buildings.value = results[0] as List<Building>;
      programs.value = results[1] as List<Program>;
    } on ApiException catch (e) {
      AppSnackbar.show(e.message);
    } finally {
      isLoadingRef.value = false;
    }
  }

  Future<void> addBuilding(String name) async {
    try {
      final b = await _refRepo.createBuilding(name);
      buildings.add(b);
    } on ApiException catch (e) {
      AppSnackbar.show(e.message);
    }
  }

  Future<void> editBuilding(Building building, String newName) async {
    try {
      final updated = await _refRepo.updateBuilding(building.id, newName);
      final idx = buildings.indexWhere((b) => b.id == building.id);
      if (idx != -1) buildings[idx] = updated;
    } on ApiException catch (e) {
      AppSnackbar.show(e.message);
    }
  }

  Future<void> deleteBuilding(Building building) async {
    try {
      await _refRepo.deleteBuilding(building.id);
      buildings.removeWhere((b) => b.id == building.id);
    } on ApiException catch (e) {
      AppSnackbar.show(e.message);
    }
  }

  Future<void> addRoom(Building building, String number) async {
    try {
      final room = await _refRepo.createRoom(building.id, number);
      final idx = buildings.indexWhere((b) => b.id == building.id);
      if (idx != -1) {
        final updated = Building(
          id: building.id,
          name: building.name,
          rooms: [...building.rooms, room],
        );
        buildings[idx] = updated;
      }
    } on ApiException catch (e) {
      AppSnackbar.show(e.message);
    }
  }

  Future<void> editRoom(Room room, String newNumber) async {
    try {
      final updated = await _refRepo.updateRoom(room.id, newNumber);
      for (int i = 0; i < buildings.length; i++) {
        final b = buildings[i];
        final rIdx = b.rooms.indexWhere((r) => r.id == room.id);
        if (rIdx != -1) {
          final updatedRooms = List<Room>.from(b.rooms)..[rIdx] = updated;
          buildings[i] = Building(id: b.id, name: b.name, rooms: updatedRooms);
          break;
        }
      }
    } on ApiException catch (e) {
      AppSnackbar.show(e.message);
    }
  }

  Future<void> deleteRoom(Room room) async {
    try {
      await _refRepo.deleteRoom(room.id);
      for (int i = 0; i < buildings.length; i++) {
        final b = buildings[i];
        if (b.rooms.any((r) => r.id == room.id)) {
          buildings[i] = Building(
            id: b.id,
            name: b.name,
            rooms: b.rooms.where((r) => r.id != room.id).toList(),
          );
          break;
        }
      }
    } on ApiException catch (e) {
      AppSnackbar.show(e.message);
    }
  }

  Future<void> addProgram(String name) async {
    try {
      final p = await _refRepo.createProgram(name);
      programs.add(p);
    } on ApiException catch (e) {
      AppSnackbar.show(e.message);
    }
  }

  Future<void> editProgram(Program program, String newName) async {
    try {
      final updated = await _refRepo.updateProgram(program.id, newName);
      final idx = programs.indexWhere((p) => p.id == program.id);
      if (idx != -1) programs[idx] = updated;
    } on ApiException catch (e) {
      AppSnackbar.show(e.message);
    }
  }

  Future<void> deleteProgram(Program program) async {
    try {
      await _refRepo.deleteProgram(program.id);
      programs.removeWhere((p) => p.id == program.id);
    } on ApiException catch (e) {
      AppSnackbar.show(e.message);
    }
  }

  // --- USERS ---

  Future<void> loadUsers() async {
    isLoadingUsers.value = true;
    try {
      users.value = await _adminRepo.fetchUsers();
    } on ApiException catch (e) {
      AppSnackbar.show(e.message);
    } finally {
      isLoadingUsers.value = false;
    }
  }

  Future<void> createUser({
    required String fullName,
    required String email,
    required String password,
    required UserRole role,
    String? buildingId,
  }) async {
    try {
      final user = await _adminRepo.createUser(
        fullName: fullName,
        email: email,
        password: password,
        role: role,
        buildingId: buildingId,
      );
      users.add(user);
    } on ApiException catch (e) {
      AppSnackbar.show(e.message);
    }
  }

  Future<void> updateUserRole(AppUser user, UserRole role, {String? buildingId}) async {
    try {
      final updated = await _adminRepo.updateUser(user.id, role: role, buildingId: buildingId);
      final idx = users.indexWhere((u) => u.id == user.id);
      if (idx != -1) users[idx] = updated;
    } on ApiException catch (e) {
      AppSnackbar.show(e.message);
    }
  }

  Future<void> deactivateUser(AppUser user) async {
    try {
      await _adminRepo.deactivateUser(user.id);
      users.removeWhere((u) => u.id == user.id);
      AppSnackbar.show('Compte désactivé');
    } on ApiException catch (e) {
      AppSnackbar.show(e.message);
    }
  }
}
