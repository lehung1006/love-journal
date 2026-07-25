import 'dart:convert';

import '../../domain/entities/journal_entities.dart';

abstract final class JournalDataDraftCodec {
  static String encode(JournalData data) {
    return jsonEncode({
      'version': 2,
      'tags': data.tags.map(_tagToJson).toList(growable: false),
      'memories': data.memories.map(_memoryToJson).toList(growable: false),
      'locations': data.locations.map(_locationToJson).toList(growable: false),
    });
  }

  static JournalData applyDraft(JournalData seed, String rawDraft) {
    final decoded = jsonDecode(rawDraft);
    if (decoded is! Map<String, dynamic>) {
      return seed;
    }

    final tags = (decoded['tags'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(_tagFromJson)
        .toList(growable: false);
    final memories =
        (decoded['memories'] as List<dynamic>? ?? const [])
            .whereType<Map<String, dynamic>>()
            .map(_memoryFromJson)
            .toList()
          ..sort((a, b) => b.date.compareTo(a.date));
    final locations = (decoded['locations'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(_locationFromJson)
        .toList(growable: false);

    if (memories.isEmpty) {
      return seed;
    }

    return seed.copyWith(
      memories: List.unmodifiable(memories),
      tags: List.unmodifiable(tags.isEmpty ? seed.tags : tags),
      locations: List.unmodifiable(
        locations.isEmpty ? seed.locations : locations,
      ),
    );
  }

  static Map<String, dynamic> _tagToJson(MemoryTag tag) {
    return {
      'id': tag.id,
      'name': tag.name,
      'colorKey': tag.colorKey,
      'isSystem': tag.isSystem,
      'createdAt': tag.createdAt.toIso8601String(),
      'updatedAt': tag.updatedAt.toIso8601String(),
    };
  }

  static MemoryTag _tagFromJson(Map<String, dynamic> json) {
    return MemoryTag(
      id: json['id'] as String,
      name: json['name'] as String,
      colorKey: json['colorKey'] as String? ?? 'rose',
      isSystem: json['isSystem'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  static Map<String, dynamic> _memoryToJson(Memory memory) {
    return {
      'id': memory.id,
      'title': memory.title,
      'date': memory.date.toIso8601String(),
      'category': memory.category.name,
      'phase': memory.phase.name,
      'primaryTagId': memory.primaryTagId,
      'locationId': memory.locationId,
      'locationName': memory.locationName,
      'latitude': memory.latitude,
      'longitude': memory.longitude,
      'placeId': memory.placeId,
      'media': memory.media.map(_mediaToJson).toList(growable: false),
      'mediaGroups': memory.mediaGroups
          .map(_mediaGroupToJson)
          .toList(growable: false),
      'coverMediaId': memory.coverMediaId,
      'story': memory.story,
      'note': memory.note,
      'favoriteMoment': memory.favoriteMoment,
      'messageForHer': memory.messageForHer,
      'voiceNoteUrl': memory.voiceNoteUrl,
      'voiceMessages': memory.voiceMessages
          .map(_voiceMessageToJson)
          .toList(growable: false),
      'isFeatured': memory.isFeatured,
      'createdAt': memory.createdAt.toIso8601String(),
      'updatedAt': memory.updatedAt.toIso8601String(),
      'deletedAt': memory.deletedAt?.toIso8601String(),
    };
  }

  static Memory _memoryFromJson(Map<String, dynamic> json) {
    final media = (json['media'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(_mediaFromJson)
        .toList(growable: false);
    final mediaGroups = (json['mediaGroups'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(_mediaGroupFromJson)
        .toList(growable: false);
    final category = _enumByName(
      MemoryCategory.values,
      json['category'] as String?,
      MemoryCategory.daily,
    );

    return Memory(
      id: json['id'] as String,
      title: json['title'] as String,
      date: DateTime.parse(json['date'] as String),
      category: category,
      phase: _enumByName(
        RelationshipPhase.values,
        json['phase'] as String?,
        RelationshipPhase.year3,
      ),
      primaryTagId:
          json['primaryTagId'] as String? ??
          MemoryTag.systemIdForCategory(category),
      locationId: json['locationId'] as String? ?? json['placeId'] as String?,
      locationName: json['locationName'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      placeId: json['placeId'] as String?,
      media: media,
      mediaGroups: mediaGroups.isEmpty && media.isNotEmpty
          ? [
              MemoryMediaGroup(
                id: '${json['id']}-media-group-1',
                items: media,
                sortOrder: 0,
              ),
            ]
          : mediaGroups,
      coverMediaId: json['coverMediaId'] as String?,
      story: json['story'] as String? ?? '',
      note: json['note'] as String?,
      favoriteMoment: json['favoriteMoment'] as String?,
      messageForHer: json['messageForHer'] as String?,
      voiceNoteUrl: json['voiceNoteUrl'] as String?,
      voiceMessages: (json['voiceMessages'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(_voiceMessageFromJson)
          .toList(growable: false),
      isFeatured: json['isFeatured'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      deletedAt: json['deletedAt'] == null
          ? null
          : DateTime.parse(json['deletedAt'] as String),
    );
  }

  static Map<String, dynamic> _mediaToJson(MemoryMedia media) {
    return {
      'id': media.id,
      'type': media.type.name,
      'uri': media.uri,
      'thumbnailUri': media.thumbnailUri,
      'width': media.width,
      'height': media.height,
      'alt': media.alt,
    };
  }

  static MemoryMedia _mediaFromJson(Map<String, dynamic> json) {
    return MemoryMedia(
      id: json['id'] as String,
      type: _enumByName(
        MemoryMediaType.values,
        json['type'] as String?,
        MemoryMediaType.image,
      ),
      uri: json['uri'] as String,
      thumbnailUri: json['thumbnailUri'] as String?,
      width: json['width'] as int?,
      height: json['height'] as int?,
      alt: json['alt'] as String?,
    );
  }

  static Map<String, dynamic> _mediaGroupToJson(MemoryMediaGroup group) {
    return {
      'id': group.id,
      'title': group.title,
      'note': group.note,
      'items': group.items.map(_mediaToJson).toList(growable: false),
      'sortOrder': group.sortOrder,
    };
  }

  static MemoryMediaGroup _mediaGroupFromJson(Map<String, dynamic> json) {
    return MemoryMediaGroup(
      id: json['id'] as String,
      title: json['title'] as String?,
      note: json['note'] as String?,
      items: (json['items'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(_mediaFromJson)
          .toList(growable: false),
      sortOrder: json['sortOrder'] as int? ?? 0,
    );
  }

  static Map<String, dynamic> _voiceMessageToJson(MemoryVoiceMessage message) {
    return {
      'id': message.id,
      'uri': message.uri,
      'source': message.source.name,
      'fileName': message.fileName,
      'title': message.title,
      'durationSeconds': message.durationSeconds,
      'waveform': message.waveform,
      'createdAt': message.createdAt.toIso8601String(),
    };
  }

  static Map<String, dynamic> _locationToJson(MemoryLocation location) {
    return {
      'id': location.id,
      'displayName': location.displayName,
      'formattedAddress': location.formattedAddress,
      'latitude': location.latitude,
      'longitude': location.longitude,
      'googlePlaceId': location.googlePlaceId,
      'source': location.source.name,
      'createdAt': location.createdAt.toIso8601String(),
      'updatedAt': location.updatedAt.toIso8601String(),
    };
  }

  static MemoryLocation _locationFromJson(Map<String, dynamic> json) {
    return MemoryLocation(
      id: json['id'] as String,
      displayName: json['displayName'] as String,
      formattedAddress: json['formattedAddress'] as String?,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      googlePlaceId: json['googlePlaceId'] as String?,
      source: _enumByName(
        MemoryLocationSource.values,
        json['source'] as String?,
        MemoryLocationSource.manual,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  static MemoryVoiceMessage _voiceMessageFromJson(Map<String, dynamic> json) {
    return MemoryVoiceMessage(
      id: json['id'] as String,
      uri: json['uri'] as String,
      source: _enumByName(
        MemoryVoiceMessageSource.values,
        json['source'] as String?,
        MemoryVoiceMessageSource.imported,
      ),
      fileName: json['fileName'] as String?,
      title: json['title'] as String?,
      durationSeconds: json['durationSeconds'] as int?,
      waveform: (json['waveform'] as List<dynamic>? ?? const [])
          .whereType<num>()
          .map((value) => value.toDouble())
          .toList(growable: false),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  static T _enumByName<T extends Enum>(
    List<T> values,
    String? name,
    T fallback,
  ) {
    for (final value in values) {
      if (value.name == name) {
        return value;
      }
    }
    return fallback;
  }
}
