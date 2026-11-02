import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/models/reclamation_enums.dart';
import 'reclamation_visuals.dart';

/// Retourne le commentaire saisi (éventuellement vide) ou `null` si annulé.
class StatusChangeDialog extends StatefulWidget {
  const StatusChangeDialog({super.key, required this.target});

  final ReclamationStatus target;

  static Future<String?> show(ReclamationStatus target) {
    return Get.dialog<String>(StatusChangeDialog(target: target));
  }

  @override
  State<StatusChangeDialog> createState() => _StatusChangeDialogState();
}

class _StatusChangeDialogState extends State<StatusChangeDialog> {
  final _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.target.actionLabel),
      content: TextField(
        controller: _commentController,
        maxLines: 3,
        maxLength: 500,
        decoration: const InputDecoration(labelText: 'Commentaire (optionnel)'),
      ),
      actions: [
        TextButton(onPressed: Get.back, child: const Text('Annuler')),
        FilledButton(
          onPressed: () => Get.back(result: _commentController.text.trim()),
          child: const Text('Confirmer'),
        ),
      ],
    );
  }
}
