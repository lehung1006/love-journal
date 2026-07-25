import 'dart:convert';

import 'package:flutter/foundation.dart';

/// Writes diagnostics that are useful while developing locally.
///
/// Keep secrets, including API keys and authorization headers, out of these
/// messages. This helper is intentionally silent in release builds.
class AppDebugLogger {
  const AppDebugLogger._();

  static void info(String scope, String message) {
    if (!kDebugMode) {
      return;
    }
    debugPrint('[$scope] $message');
  }

  static void block(String scope, String title, String content) {
    if (!kDebugMode) {
      return;
    }
    debugPrint('[$scope] ----- $title -----');
    for (final line in content.split('\n')) {
      debugPrint('[$scope] $line');
    }
    debugPrint('[$scope] ----- end $title -----');
  }

  static void json(String scope, String title, Object? value) {
    if (!kDebugMode) {
      return;
    }
    String content;
    try {
      content = const JsonEncoder.withIndent('  ').convert(value);
    } on JsonUnsupportedObjectError {
      content = '$value';
    }
    block(scope, title, content);
  }

  static String maskSecret(String value, {int visibleSuffixLength = 4}) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return '<empty>';
    }
    final suffixLength = visibleSuffixLength.clamp(0, trimmed.length);
    final suffix = trimmed.substring(trimmed.length - suffixLength);
    return '${'*' * (trimmed.length - suffixLength)}$suffix';
  }

  static void error(
    String scope,
    String message, {
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (!kDebugMode) {
      return;
    }
    final suffix = error == null ? '' : ' Error: $error';
    debugPrint('[$scope] $message$suffix');
    if (stackTrace != null) {
      debugPrintStack(stackTrace: stackTrace, label: '[$scope] stack trace');
    }
  }
}
