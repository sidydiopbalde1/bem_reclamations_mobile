import 'package:get/get.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../data/models/reclamation.dart';
import '../../../../data/models/reclamation_enums.dart';
import '../../../../data/repositories/reclamation_repository.dart';
import '../../../../routes/app_routes.dart';
import '../../../../services/auth_service.dart';

class ReclamationListController extends GetxController with StateMixin<List<Reclamation>> {
  ReclamationListController(this._repository, this._authService);

  final ReclamationRepository _repository;
  final AuthService _authService;

  final statusFilter = Rxn<ReclamationStatus>();
  final searchQuery = ''.obs;
  final isLoadingMore = false.obs;
  final hasMore = false.obs;

  late final Worker _filterWorker;
  Worker? _searchWorker;

  int _offset = 0;

  // Cache pour les stats -mis à jour uniquement lors du fetch sans filtre et sans recherche
  var _cachedAll = <Reclamation>[];

  Map<ReclamationStatus, int> get statusCounts => {
        for (final s in ReclamationStatus.values)
          s: _cachedAll.where((r) => r.status == s).length,
      };

  @override
  void onInit() {
    super.onInit();
    _filterWorker = ever(statusFilter, (_) => fetch());
    _searchWorker = debounce(searchQuery, (_) => fetch(), time: const Duration(milliseconds: 400));
    fetch();
  }

  Future<void> fetch({bool showLoader = true, bool append = false}) async {
    if (!append) {
      _offset = 0;
      if (showLoader) change(null, status: RxStatus.loading());
    }

    try {
      final items = await _repository.fetchAll(
        status: statusFilter.value,
        search: searchQuery.value.isEmpty ? null : searchQuery.value,
        offset: _offset,
      );

      hasMore.value = items.length >= 50;
      _offset += items.length;

      if (append) {
        final current = state ?? [];
        final merged = current + items;
        change(merged, status: merged.isEmpty ? RxStatus.empty() : RxStatus.success());
      } else {
        // Met à jour le cache stats seulement quand on charge sans filtre et sans recherche
        if (statusFilter.value == null && searchQuery.value.isEmpty) {
          _cachedAll = List.unmodifiable(items);
        }
        change(items, status: items.isEmpty ? RxStatus.empty() : RxStatus.success());
      }
    } on ApiException catch (error) {
      change(null, status: RxStatus.error(error.message));
    }
  }

  Future<void> loadMore() async {
    if (!hasMore.value || isLoadingMore.value) return;
    isLoadingMore.value = true;
    await fetch(showLoader: false, append: true);
    isLoadingMore.value = false;
  }

  void filterBy(ReclamationStatus? status) => statusFilter.value = status;

  Future<void> openNewReclamation() async {
    final created = await Get.toNamed(AppRoutes.newReclamation);
    if (created == true) await fetch(showLoader: false);
  }

  Future<void> openDetail(String id) async {
    await Get.toNamed(AppRoutes.reclamationDetail(id));
    await fetch(showLoader: false);
  }

  Future<void> logout() => _authService.logout();

  @override
  void onClose() {
    _filterWorker.dispose();
    _searchWorker?.dispose();
    super.onClose();
  }
}
