import 'dart:io';

import 'package:flutter/material.dart';

Widget buildLocalOrAssetImage({
  required String path,
  required BoxFit fit,
  required ImageErrorWidgetBuilder errorBuilder,
}) {
  if (path.startsWith('assets/')) {
    return Image.asset(path, fit: fit, errorBuilder: errorBuilder);
  }
  return Image.file(File(path), fit: fit, errorBuilder: errorBuilder);
}
