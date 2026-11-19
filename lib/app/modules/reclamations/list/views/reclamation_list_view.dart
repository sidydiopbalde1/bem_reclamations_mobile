import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../../../core/widgets/stat_counter.dart';
import '../../../../data/models/app_user.dart';
import '../../../../data/models/reclamation.dart';
import '../../../../data/models/reclamation_enums.dart';
import '../../../../routes/app_routes.dart';
import '../../../../services/auth_service.dart';
import '../../widgets/reclamation_card.dart';
import '../../widgets/reclamation_visuals.dart';
import '../controllers/reclamation_list_controller.dart';

class ReclamationListView extends GetView<ReclamationListController> {
  const ReclamationListView({super.key});

  Future<void> _refresh() => controller.fetch(showLoader: false);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Réclamations'),
        actions: [
          if (Get.find<AuthService>().currentUser.value?.role == UserRole.admin)
            IconButton(
              tooltip: 'Administration',
              icon: const Icon(Icons.admin_panel_settings_outlined),
              onPressed: () => Get.toNamed(AppRoutes.admin),
            ),
          IconButton(
            tooltip: 'Mon profil',
            icon: const Icon(Icons.person_outline),
            onPressed: () => Get.toNamed(AppRoutes.profile),
          ),
          IconButton(
            tooltip: 'Se déconnecter',
            icon: const Icon(Icons.logout),
            onPressed: controller.logout,
          ),
        ],
      ),
      body: Column(
        children: [
          if (Get.find<AuthService>().currentUser.value?.role != UserRole.delegue)
            _StatsDashboard(controller: controller),
          _StatusFilterBar(controller: controller),
          _SearchBar(controller: controller),
          Expanded(
            child: controller.obx(
              (items) => RefreshIndicator(
                onRefresh: _refresh,
                child: _ReclamationList(items: items!),
              ),
              onLoading: const LoadingView(),
              onEmpty: RefreshIndicator(
                onRefresh: _refresh,
                child: const _EmptyState(),
              ),
              onError: (message) => ErrorView(
                message: message ?? 'Erreur',
                onRetry: controller.fetch,
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: controller.openNewReclamation,
        icon: const Icon(Icons.add),
        label: const Text('Signaler'),
      ),
    );
  }
}

class _StatsDashboard extends StatelessWidget {
  const _StatsDashboard({required this.controller});

  final ReclamationListController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final counts = controller.statusCounts;
      final selectedFilter = controller.statusFilter.value;
      return Container(
        color: AppColors.surface,
        padding: const EdgeInsets.fromLTRB(8, 12, 8, 4),
        child: Row(
          children: [
            for (final status in ReclamationStatus.values)
              StatCounter(
                count: counts[status] ?? 0,
                label: status.label,
                color: status.color,
                isSelected: selectedFilter == status,
                onTap: () => controller.filterBy(
                  selectedFilter == status ? null : status,
                ),
              ),
          ],
        ),
      );
    });
  }
}

class _StatusFilterBar extends StatelessWidget {
  const _StatusFilterBar({required this.controller});

  final ReclamationListController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      child: SizedBox(
        height: 52,
        child: Obx(() {
          final selected = controller.statusFilter.value;
          return ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            children: [
              _FilterChip(
                label: 'Toutes',
                isSelected: selected == null,
                color: AppColors.primary,
                onSelected: () => controller.filterBy(null),
              ),
              for (final status in ReclamationStatus.values)
                _FilterChip(
                  label: status.label,
                  isSelected: selected == status,
                  color: status.color,
                  onSelected: () => controller.filterBy(status),
                ),
            ],
          );
        }),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.color,
    required this.onSelected,
  });

  final String label;
  final bool isSelected;
  final Color color;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onSelected(),
        selectedColor: color.withValues(alpha: 0.15),
        checkmarkColor: color,
        labelStyle: TextStyle(
          color: isSelected ? color : AppColors.secondaryText,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
        side: BorderSide(color: isSelected ? color : AppColors.divider),
        backgroundColor: AppColors.surface,
        showCheckmark: false,
      ),
    );
  }
}

class _SearchBar extends StatefulWidget {
  const _SearchBar({required this.controller});

  final ReclamationListController controller;

  @override
  State<_SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<_SearchBar> {
  late final TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.controller.searchQuery.value);
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
      child: Obx(() {
        final hasText = widget.controller.searchQuery.value.isNotEmpty;
        return TextField(
          controller: _textController,
          onChanged: (value) => widget.controller.searchQuery.value = value,
          decoration: InputDecoration(
            hintText: 'Rechercher…',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: hasText
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _textController.clear();
                      widget.controller.searchQuery.value = '';
                    },
                  )
                : null,
          ),
        );
      }),
    );
  }
}

class _ReclamationList extends GetView<ReclamationListController> {
  const _ReclamationList({required this.items});

  final List<Reclamation> items;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 88),
      itemCount: items.length + 1,
      itemBuilder: (_, index) {
        if (index == items.length) {
          return const _LoadMoreButton();
        }
        final reclamation = items[index];
        return ReclamationCard(
          reclamation: reclamation,
          onTap: () => controller.openDetail(reclamation.id),
        );
      },
    );
  }
}

class _LoadMoreButton extends GetView<ReclamationListController> {
  const _LoadMoreButton();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (!controller.hasMore.value) return const SizedBox.shrink();
      if (controller.isLoadingMore.value) {
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: Center(child: CircularProgressIndicator()),
        );
      }
      return Center(
        child: TextButton(
          onPressed: controller.loadMore,
          child: const Text('Charger plus'),
        ),
      );
    });
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: const [
        SizedBox(height: 120),
        Icon(Icons.inbox_outlined, size: 64, color: AppColors.secondaryText),
        SizedBox(height: 12),
        Text(
          'Aucune réclamation',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.secondaryText),
        ),
      ],
    );
  }
}
