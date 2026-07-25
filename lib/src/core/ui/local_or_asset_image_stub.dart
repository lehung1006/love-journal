import 'package:flutter/material.dart';

Widget buildLocalOrAssetImage({
  required String path,
  required BoxFit fit,
  required ImageErrorWidgetBuilder errorBuilder,
}) {
  return Image.asset(path, fit: fit, errorBuilder: errorBuilder);
}
