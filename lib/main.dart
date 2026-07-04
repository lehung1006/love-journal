import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_love_journal/src/app/love_journal_app.dart';

void main() {
  runApp(const ProviderScope(child: LoveJournalApp()));
}
