import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/utils/validators.dart';

class EntityFormDialog extends StatefulWidget {
  const EntityFormDialog({super.key, required this.title, this.initialValue});

  final String title;
  final String? initialValue;

  static Future<String?> show({required String title, String? initialValue}) {
    return Get.dialog<String>(
      EntityFormDialog(title: title, initialValue: initialValue),
    );
  }

  @override
  State<EntityFormDialog> createState() => _EntityFormDialogState();
}

class _EntityFormDialogState extends State<EntityFormDialog> {
  late final _ctrl = TextEditingController(text: widget.initialValue);
  final _key = GlobalKey<FormState>();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: Form(
        key: _key,
        child: TextFormField(
          controller: _ctrl,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Nom'),
          validator: Validators.required,
        ),
      ),
      actions: [
        TextButton(
          onPressed: Get.back,
          child: const Text('Annuler'),
        ),
        FilledButton(
          onPressed: () {
            if (_key.currentState!.validate()) {
              Get.back(result: _ctrl.text.trim());
            }
          },
          child: const Text('Confirmer'),
        ),
      ],
    );
  }
}
