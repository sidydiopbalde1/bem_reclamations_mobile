import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_date_format.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../../../data/models/reclamation.dart';
import '../../../../data/models/reclamation_enums.dart';
import '../../widgets/priority_badge.dart';
import '../../widgets/reclamation_visuals.dart';
import '../../widgets/status_change_dialog.dart';
import '../../widgets/status_chip.dart';
import '../controllers/reclamation_detail_controller.dart';

const _timelineDotSize = 14.0;
const _timelineRailWidth = 32.0;

class ReclamationDetailView extends GetView<ReclamationDetailController> {
  const ReclamationDetailView({super.key});

  static const _defaultTitle = Text('Réclamation');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: controller.obx(
          (r) => Text(r!.reference),
          onLoading: _defaultTitle,
          onError: (_) => _defaultTitle,
        ),
      ),
      body: controller.obx(
        (r) => _ReclamationDetails(reclamation: r!),
        onLoading: const LoadingView(),
        onError: (message) => ErrorView(
          message: message ?? 'Erreur',
          onRetry: controller.fetch,
        ),
      ),
      bottomNavigationBar: controller.canManage
          ? controller.obx(
              (r) => _StatusActions(reclamation: r!),
              onLoading: const SizedBox.shrink(),
              onError: (_) => const SizedBox.shrink(),
            )
          : null,
    );
  }
}

class _ReclamationDetails extends StatelessWidget {
  const _ReclamationDetails({required this.reclamation});

  final Reclamation reclamation;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        _HeroCard(reclamation: reclamation),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _InfoCard(
                title: 'Localisation',
                icon: Icons.meeting_room_outlined,
                value: reclamation.location,
              ),
              const SizedBox(height: 8),
              _InfoCard(
                title: 'Programme',
                icon: Icons.school_outlined,
                value: reclamation.programName,
              ),
              const SizedBox(height: 8),
              _InfoCard(
                title: 'Déclarant',
                icon: Icons.person_outline,
                value: reclamation.reportedByName,
                subtitle: AppDateFormat.dateTime(reclamation.createdAt),
              ),
              const SizedBox(height: 8),
              _DescriptionCard(description: reclamation.description),
              const SizedBox(height: 16),
              Text(
                'Historique',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 8),
              _Timeline(events: reclamation.events.reversed.toList()),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ],
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.reclamation});

  final Reclamation reclamation;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: reclamation.status.color.withValues(alpha: 0.08),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                reclamation.reference,
                style: const TextStyle(
                  color: AppColors.secondaryText,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              StatusChip(status: reclamation.status),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  reclamation.category.icon,
                  size: 28,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  reclamation.category.label,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurface,
                      ),
                ),
              ),
              PriorityBadge(priority: reclamation.priority),
            ],
          ),
        ],
      ),
    );
  }
}

/// Carte « icône + libellé + valeur » (+ sous-titre facultatif).
class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.title,
    required this.icon,
    required this.value,
    this.subtitle,
  });

  final String title;
  final IconData icon;
  final String value;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final subtitle = this.subtitle;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(icon, size: 18, color: AppColors.primary),
            const SizedBox(width: 10),
            // Expanded : évite le débordement sur une valeur longue.
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _CardLabel(title),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle,
                      style: const TextStyle(color: AppColors.secondaryText, fontSize: 12),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DescriptionCard extends StatelessWidget {
  const _DescriptionCard({required this.description});

  final String description;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.description_outlined, size: 18, color: AppColors.primary),
                SizedBox(width: 10),
                _CardLabel('Description'),
              ],
            ),
            const SizedBox(height: 8),
            Text(description, style: const TextStyle(fontSize: 14)),
          ],
        ),
      ),
    );
  }
}

class _CardLabel extends StatelessWidget {
  const _CardLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.secondaryText,
        fontSize: 11,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

class _Timeline extends StatelessWidget {
  const _Timeline({required this.events});

  final List<ReclamationEvent> events;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final (index, event) in events.indexed)
          _TimelineItem(event: event, isLast: index == events.length - 1),
      ],
    );
  }
}

class _TimelineItem extends StatelessWidget {
  const _TimelineItem({required this.event, required this.isLast});

  final ReclamationEvent event;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    // La Row étire la ligne verticale à la hauteur de la carte :
    // IntrinsicHeight lui donne une hauteur finie dans la ListView.
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _TimelineRail(color: event.toStatus.color, showLine: !isLast),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: 8, bottom: isLast ? 0 : 16),
              child: _TimelineCard(event: event),
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelineRail extends StatelessWidget {
  const _TimelineRail({required this.color, required this.showLine});

  final Color color;
  final bool showLine;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _timelineRailWidth,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          if (showLine)
            Positioned(
              top: _timelineDotSize,
              bottom: 0,
              child: Container(width: 2, color: AppColors.divider),
            ),
          Container(
            width: _timelineDotSize,
            height: _timelineDotSize,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelineCard extends StatelessWidget {
  const _TimelineCard({required this.event});

  final ReclamationEvent event;

  String get _title => event.isCreation
      ? 'Signalement créé'
      : '${event.fromStatus!.label} → ${event.toStatus.label}';

  @override
  Widget build(BuildContext context) {
    final comment = event.comment;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            const SizedBox(height: 4),
            Text(
              '${event.authorName} · ${AppDateFormat.dateTime(event.createdAt)}',
              style: const TextStyle(color: AppColors.secondaryText, fontSize: 12),
            ),
            if (comment != null && comment.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(comment, style: const TextStyle(fontSize: 13)),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatusActions extends GetView<ReclamationDetailController> {
  const _StatusActions({required this.reclamation});

  final Reclamation reclamation;

  Future<void> _onStatusPressed(ReclamationStatus target) async {
    final comment = await StatusChangeDialog.show(target);
    if (comment != null) await controller.changeStatus(target, comment);
  }

  @override
  Widget build(BuildContext context) {
    final nextStatuses = reclamation.status.nextStatuses;
    if (nextStatuses.isEmpty) return const SizedBox.shrink();

    return SafeArea(
      child: Container(
        color: AppColors.surface,
        padding: const EdgeInsets.all(12),
        child: Obx(
          () => Row(
            children: [
              for (final status in nextStatuses)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: FilledButton.tonal(
                      onPressed: controller.isUpdating.value ? null : () => _onStatusPressed(status),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(44),
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                      ),
                      child: Text(status.actionLabel),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}