import 'package:flutter/material.dart';
import 'package:get/get.dart';

abstract final class AppSnackbar {
  static void show(String message) {
    Get
      ..closeAllSnackbars()
      ..showSnackbar(
        GetSnackBar(
          message: message,
          duration: const Duration(seconds: 3),
          margin: const EdgeInsets.all(12),
          borderRadius: 8,
        ),
      );
  }
}
