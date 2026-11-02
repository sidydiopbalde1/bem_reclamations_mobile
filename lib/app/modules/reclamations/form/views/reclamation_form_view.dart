import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../../../core/widgets/step_indicator.dart';
import '../../../../data/models/reclamation_enums.dart';
import '../../../../data/models/referentials.dart';
import '../../widgets/reclamation_visuals.dart';
import '../controllers/reclamation_form_controller.dart';

class ReclamationFormView extends GetView<ReclamationFormController> {
  const ReclamationFormView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nouveau signalement')),
      body: controller.obx(
        (data) => _WizardBody(data: data!),
        onLoading: const LoadingView(),
        onError: (message) => ErrorView(
          message: message ?? 'Erreur',
          onRetry: controller.loadFormData,
        ),
      ),
    );
  }
}

class _WizardBody extends GetView<ReclamationFormController> {
  const _WizardBody({required this.data});

  final ReclamationFormData data;

  static const _stepLabels = ['Localisation', 'Détail', 'Confirmation'];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Progress indicator
        Container(
          color: AppColors.surface,
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
          child: Obx(
            () => StepIndicator(
              totalSteps: 3,
              currentStep: controller.currentStep.value,
              labels: _stepLabels,
            ),
          ),
        ),
        const Divider(height: 1),
        // Pages
        Expanded(
          child: PageView(
            controller: controller.pageController,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _Step0Location(data: data),
              const _Step1Detail(),
              const _Step2Confirmation(),
            ],
          ),
        ),
        // Navigation buttons
        const _WizardNavigation(),
      ],
    );
  }
}

class _Step0Location extends GetView<ReclamationFormController> {
  const _Step0Location({required this.data});

  final ReclamationFormData data;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: controller.step0FormKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Où se trouve le problème ?',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 20),
          DropdownButtonFormField<Building>(
            initialValue: controller.selectedBuilding.value,
            decoration: const InputDecoration(
              labelText: 'Bâtiment',
              prefixIcon: Icon(Icons.business_outlined),
            ),
            items: [
              for (final b in data.buildings)
                DropdownMenuItem(value: b, child: Text(b.name)),
            ],
            onChanged: controller.selectBuilding,
            validator: Validators.required,
          ),
          const SizedBox(height: 16),
          Obx(
            () => DropdownButtonFormField<Room>(
              key: ValueKey(controller.selectedBuilding.value?.id),
              initialValue: controller.selectedRoom.value,
              decoration: const InputDecoration(
                labelText: 'Numéro de salle',
                prefixIcon: Icon(Icons.meeting_room_outlined),
              ),
              items: [
                for (final r in controller.availableRooms)
                  DropdownMenuItem(value: r, child: Text(r.number)),
              ],
              onChanged: (room) => controller.selectedRoom.value = room,
              validator: Validators.required,
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<Program>(
            initialValue: controller.selectedProgram.value,
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: 'Programme',
              prefixIcon: Icon(Icons.school_outlined),
            ),
            items: [
              for (final p in data.programs)
                DropdownMenuItem(value: p, child: Text(p.name)),
            ],
            onChanged: (p) => controller.selectedProgram.value = p,
            validator: Validators.required,
          ),
        ],
      ),
    );
  }
}

class _Step1Detail extends GetView<ReclamationFormController> {
  const _Step1Detail();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: controller.step1FormKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Quel est le problème ?',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 16),
          Text('Type de problème', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          const _CategoryGrid(),
          const SizedBox(height: 20),
          Text('Priorité', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          const _PrioritySelector(),
          const SizedBox(height: 16),
          TextFormField(
            controller: controller.descriptionController,
            maxLines: 4,
            maxLength: 1000,
            decoration: const InputDecoration(
              labelText: 'Description',
              hintText: 'Ex. : le climatiseur fait du bruit et ne refroidit plus',
              alignLabelWithHint: true,
            ),
            validator: Validators.minLength(5),
          ),
        ],
      ),
    );
  }
}

class _CategoryGrid extends GetView<ReclamationFormController> {
  const _CategoryGrid();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final selected = controller.selectedCategory.value;
      return GridView.count(
        crossAxisCount: 4,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 0.9,
        children: [
          for (final category in ReclamationCategory.values)
            _CategoryCell(
              category: category,
              isSelected: selected == category,
              onTap: () => controller.selectedCategory.value = category,
            ),
        ],
      );
    });
  }
}

class _CategoryCell extends StatelessWidget {
  const _CategoryCell({
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  final ReclamationCategory category;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryLight : AppColors.surface,
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.divider,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.all(4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              category.icon,
              size: 24,
              color: isSelected ? AppColors.primary : AppColors.secondaryText,
            ),
            const SizedBox(height: 4),
            Text(
              category.label,
              style: TextStyle(
                fontSize: 10,
                color: isSelected ? AppColors.primary : AppColors.secondaryText,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _PrioritySelector extends GetView<ReclamationFormController> {
  const _PrioritySelector();

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Row(
        children: [
          for (final p in ReclamationPriority.values)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 4),
                child: _PriorityChip(
                  priority: p,
                  isSelected: controller.priority.value == p,
                  onTap: () => controller.priority.value = p,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _PriorityChip extends StatelessWidget {
  const _PriorityChip({
    required this.priority,
    required this.isSelected,
    required this.onTap,
  });

  final ReclamationPriority priority;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = priority.color;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.15) : AppColors.surface,
          border: Border.all(
            color: isSelected ? color : AppColors.divider,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          priority.label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.normal,
            color: isSelected ? color : AppColors.secondaryText,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class _Step2Confirmation extends GetView<ReclamationFormController> {
  const _Step2Confirmation();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final building = controller.selectedBuilding.value;
      final room = controller.selectedRoom.value;
      final program = controller.selectedProgram.value;
      final category = controller.selectedCategory.value;
      final prio = controller.priority.value;
      final desc = controller.descriptionController.text;

      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Récapitulatif',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 16),
          _ConfirmRow(icon: Icons.business_outlined, label: 'Bâtiment', value: building?.name ?? '—'),
          _ConfirmRow(icon: Icons.meeting_room_outlined, label: 'Salle', value: room?.number ?? '—'),
          _ConfirmRow(icon: Icons.school_outlined, label: 'Programme', value: program?.name ?? '—'),
          if (category != null)
            _ConfirmRow(icon: category.icon, label: 'Catégorie', value: category.label),
          _ConfirmRow(icon: Icons.flag_outlined, label: 'Priorité', value: prio.label),
          const Divider(height: 24),
          Text('Description', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.divider),
            ),
            child: Text(desc.isEmpty ? '—' : desc),
          ),
        ],
      );
    });
  }
}

class _ConfirmRow extends StatelessWidget {
  const _ConfirmRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.secondaryText),
          const SizedBox(width: 10),
          Text(
            '$label : ',
            style: const TextStyle(color: AppColors.secondaryText, fontSize: 13),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

class _WizardNavigation extends GetView<ReclamationFormController> {
  const _WizardNavigation();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      child: Obx(() {
        final step = controller.currentStep.value;
        final isLast = step == 2;
        final isFirst = step == 0;

        return Row(
          children: [
            if (!isFirst)
              Expanded(
                child: OutlinedButton(
                  onPressed: controller.previousStep,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                    side: const BorderSide(color: AppColors.primary),
                    foregroundColor: AppColors.primary,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                  ),
                  child: const Text('Précédent'),
                ),
              ),
            if (!isFirst) const SizedBox(width: 12),
            Expanded(
              child: isLast
                  ? Obx(
                      () => FilledButton.icon(
                        onPressed: controller.isSubmitting.value ? null : controller.submit,
                        icon: controller.isSubmitting.value
                            ? const SizedBox.square(
                                dimension: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.send),
                        label: const Text('Soumettre'),
                      ),
                    )
                  : FilledButton(
                      onPressed: () => controller.nextStep(),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                      ),
                      child: const Text('Suivant'),
                    ),
            ),
          ],
        );
      }),
    );
  }
}
