import 'dart:convert';

import 'package:flutter/services.dart';

import '../domain/journal_models.dart';

class JournalRepository {
  JournalRepository({AssetBundle? assetBundle})
    : _assetBundle = assetBundle ?? rootBundle;

  final AssetBundle _assetBundle;

  Future<JournalData> load() async {
    final memoriesJson = await _loadList('assets/data/memories.json');
    final lettersJson = await _loadList('assets/data/letters.json');
    final placesJson = await _loadList('assets/data/places.json');

    final memories =
        memoriesJson
            .map((item) => Memory.fromJson(item as Map<String, dynamic>))
            .toList()
          ..sort((a, b) => b.date.compareTo(a.date));

    final letters = lettersJson
        .map((item) => Letter.fromJson(item as Map<String, dynamic>))
        .toList(growable: false);

    final places = placesJson
        .map((item) => Place.fromJson(item as Map<String, dynamic>))
        .toList(growable: false);

    return JournalData(
      memories: List.unmodifiable(memories),
      letters: letters,
      places: places,
    );
  }

  Future<List<dynamic>> _loadList(String assetPath) async {
    final raw = await _assetBundle.loadString(assetPath);
    return jsonDecode(raw) as List<dynamic>;
  }
}
