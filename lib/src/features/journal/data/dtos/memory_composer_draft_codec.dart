import 'dart:convert';

import '../../domain/entities/journal_entities.dart';

abstract final class MemoryComposerDraftCodec {
  static const _version = 1;

  static String encode(MemoryComposerDraft draft) {
    return jsonEncode({
      'version': _version,
      'titleOverride': draft.titleOverride,
      'story': draft.story,
      'date': draft.date.toIso8601String(),
      'primaryTagId': draft.primaryTagId,
      'location': _encodeLocation(draft.locationSelection),
      'voiceMessages': draft.voiceMessages.map(_encodeVoice).toList(),
      'mediaGroups': draft.mediaGroups.map(_encodeMediaGroup).toList(),
      'category': draft.category.name,
      'phase': draft.phase.name,
      'updatedAt': draft.updatedAt.toIso8601String(),
    });
  }

  static MemoryComposerDraft decode(String source) {
    final json = jsonDecode(source) as Map<String, dynamic>;
    if (json['version'] != _version) {
      throw const FormatException('Unsupported memory composer draft version.');
    }

    return MemoryComposerDraft(
      titleOverride: json['titleOverride'] as String?,
      story: json['story'] as String? ?? '',
      date: DateTime.parse(json['date'] as String),
      primaryTagId: json['primaryTagId'] as String,
      locationSelection: _decodeLocation(
        json['location'] as Map<String, dynamic>?,
      ),
      voiceMessages: (json['voiceMessages'] as List<dynamic>? ?? const [])
          .map((item) => _decodeVoice(item as Map<String, dynamic>))
          .toList(growable: false),
      mediaGroups: (json['mediaGroups'] as List<dynamic>? ?? const [])
          .map((item) => _decodeMediaGroup(item as Map<String, dynamic>))
          .toList(growable: false),
      category: MemoryCategory.values.byName(
        json['category'] as String? ?? MemoryCategory.daily.name,
      ),
      phase: RelationshipPhase.values.byName(
        json['phase'] as String? ?? RelationshipPhase.year3.name,
      ),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  static Map<String, dynamic>? _encodeLocation(
    MemoryLocationSelection? selection,
  ) {
    if (selection == null) {
      return null;
    }
    final existingId = selection.existingLocationId;
    if (existingId != null) {
      return {'kind': 'existing', 'locationId': existingId};
    }
    final draft = selection.draftLocation;
    if (draft == null) {
      return null;
    }
    return {
      'kind': 'draft',
      'displayName': draft.displayName,
      'formattedAddress': draft.formattedAddress,
      'latitude': draft.latitude,
      'longitude': draft.longitude,
      'googlePlaceId': draft.googlePlaceId,
      'source': draft.source.name,
    };
  }

  static MemoryLocationSelection? _decodeLocation(Map<String, dynamic>? json) {
    if (json == null) {
      return null;
    }
    if (json['kind'] == 'existing') {
      return MemoryLocationSelection.existing(json['locationId'] as String);
    }
    return MemoryLocationSelection.draft(
      MemoryLocationDraft(
        displayName: json['displayName'] as String,
        formattedAddress: json['formattedAddress'] as String?,
        latitude: (json['latitude'] as num).toDouble(),
        longitude: (json['longitude'] as num).toDouble(),
        googlePlaceId: json['googlePlaceId'] as String?,
        source: MemoryLocationSource.values.byName(json['source'] as String),
      ),
    );
  }

  static Map<String, dynamic> _encodeVoice(MemoryVoiceMessage message) {
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

  static MemoryVoiceMessage _decodeVoice(Map<String, dynamic> json) {
    return MemoryVoiceMessage(
      id: json['id'] as String,
      uri: json['uri'] as String,
      source: MemoryVoiceMessageSource.values.byName(json['source'] as String),
      fileName: json['fileName'] as String?,
      title: json['title'] as String?,
      durationSeconds: json['durationSeconds'] as int?,
      waveform: (json['waveform'] as List<dynamic>? ?? const [])
          .map((value) => (value as num).toDouble())
          .toList(growable: false),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  static Map<String, dynamic> _encodeMediaGroup(MemoryMediaGroup group) {
    return {
      'id': group.id,
      'title': group.title,
      'note': group.note,
      'sortOrder': group.sortOrder,
      'items': group.items.map(_encodeMedia).toList(),
    };
  }

  static MemoryMediaGroup _decodeMediaGroup(Map<String, dynamic> json) {
    return MemoryMediaGroup(
      id: json['id'] as String,
      title: json['title'] as String?,
      note: json['note'] as String?,
      sortOrder: json['sortOrder'] as int? ?? 0,
      items: (json['items'] as List<dynamic>? ?? const [])
          .map((item) => _decodeMedia(item as Map<String, dynamic>))
          .toList(growable: false),
    );
  }

  static Map<String, dynamic> _encodeMedia(MemoryMedia media) {
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

  static MemoryMedia _decodeMedia(Map<String, dynamic> json) {
    return MemoryMedia(
      id: json['id'] as String,
      type: MemoryMediaType.values.byName(json['type'] as String),
      uri: json['uri'] as String,
      thumbnailUri: json['thumbnailUri'] as String?,
      width: json['width'] as int?,
      height: json['height'] as int?,
      alt: json['alt'] as String?,
    );
  }
}
