# Current Context - Flutter Love Journal

Last updated: 2026-07-13

## Project Intent

`flutter_love_journal` is a Flutter app for a private love journal experience.

The first version is a local-first anniversary gift app for one couple. The long-term direction is a publishable couple journal app with shared memories, private letters, maps, reminders, recap generation, messaging, stickers, video call, and watch-together journal playback.

The product principle from the design spec still matters:

> This is not a photo gallery. It is a curated emotional archive.

## Current Development Context

The app has moved beyond the original static gift MVP. It now has the foundation for a larger app:

- Riverpod for state management.
- Immutable domain-style models.
- Repository/data-source separation.
- API client abstraction, currently reading bundled JSON assets.
- GoRouter navigation with tab shell.
- Flutter gen-l10n localization for user-facing app copy.
- Local-first persistence for app session and editable journal draft.
- A redesigned local-first Time module with add/edit/delete memory flow.
- A structured Location Picker inside Add/Edit Memory with Google Places search, manual pinning, existing-location reuse, and atomic memory/location save.
- A read-only Map projection built from visible memories and their `locationId` references.
- Android application id and iOS bundle id are `vn.hung.le.lovejournal`.

The current codebase is still local-first. There is no auth, partner invite, cloud sync, real media picker, real audio recorder, or backend yet.

## Important Project Files

Design and product context:

- `docs/designs/love-journal-implementation-spec.md`
- `docs/designs/love-journal-current-ui-ux.md`
- `docs/designs/love-journal-design-tokens.json`
- `docs/designs/love-journal-figma-handoff.html`
- `docs/designs/love-journal-time-management-handoff.html`
- `docs/current-context.md`
- [Figma - Love Journal Map + Memory Location](https://www.figma.com/design/b3zJU0jnS7ZFAaJNX6G5lC)

Main Flutter app:

- `lib/main.dart`
- `lib/src/app/love_journal_app.dart`
- `lib/src/app/router/app_router.dart`
- `lib/src/app/router/app_routes.dart`
- `lib/src/app/navigation/main_navigation_shell.dart`
- `lib/src/core/theme/app_theme.dart`
- `lib/src/core/theme/app_tokens.dart`
- `lib/src/core/localization/app_localizations_extension.dart`
- `lib/l10n/app_vi.arb`
- `l10n.yaml`

Journal feature:

- `lib/src/features/journal/domain/entities/`
- `lib/src/features/journal/data/`
- `lib/src/features/journal/application/`
- `lib/src/features/journal/presentation/`

## Architecture Snapshot

The app is organized feature-first under `lib/src/features/`.

High-level flow:

```txt
main.dart
  ProviderScope
    LoveJournalApp
      MaterialApp.router
        GoRouter
          MainNavigationShell
            Home / Time / Map / Letters
```

Core layers:

```txt
core/
  api/
    ApiClient
    AssetApiClient
    ApiEndpoints
  storage/
    KeyValueStore
    SharedPreferencesKeyValueStore
  providers/
    assetBundleProvider
    apiClientProvider
    sharedPreferencesProvider
    keyValueStoreProvider
  localization/
    app_localizations_extension.dart
  config/
    map_service_config.dart
  theme/
    app_tokens.dart
    app_theme.dart
```

Journal feature layers:

```txt
features/journal/
  domain/
    entities/
    repositories/
  data/
    data_sources/
    dtos/
    repositories/
  application/
    providers/
    state/
  presentation/
    components/
    screens/
```

## State Management Decision

Riverpod is the selected state management approach.

Reasons:

- The project is expected to grow.
- Features like messaging, video call, shared playback, sync, and local database will need clear dependency boundaries.
- Riverpod works well with immutable state, repository abstractions, async loading, and testable controllers.

Current key providers:

- `journalDataProvider`
  - Now an `AsyncNotifierProvider<JournalDataController, JournalData>`.
  - Loads seed data from repository.
  - Applies local editable draft from SharedPreferences.
  - Handles create/update/delete/feature memory and create tag.

- `journalSessionControllerProvider`
  - Handles app/session preferences:
    - `hasSeenOpening`
    - `openedLetterIds`
    - `favoriteMemoryIds`
    - `lastViewedMemoryId`

- `journalRepositoryProvider`
  - Reads seed journal data through `JournalAssetApiDataSource`.

- `mapServiceConfigProvider`
  - Reads the Google Maps API key from platform-specific config.
  - Android priority: `GOOGLE_MAPS_ANDROID_API_KEY` dart define, then native manifest value.
  - iOS priority: `GOOGLE_MAPS_IOS_API_KEY` dart define, then `Info.plist` value.

- `placeSearchRepositoryProvider`
  - Calls the Google Places Web Service through a data source/repository boundary.
  - It is consumed only by Location Picker.

- `locationSearchControllerProvider`
  - Holds Location Picker query state, autocomplete suggestions, selected search result, and loading/error states.

## Navigation Snapshot

Navigation uses GoRouter with `StatefulShellRoute.indexedStack`.

Main branches:

- Home
- Time
- Map
- Letters

Important routes:

```txt
/splash
/opening
/home
/home/memories/:memoryId
/home/letters/:letterId
/home/recap
/timeline
/timeline/new-memory
/timeline/new-memory/location
/timeline/edit-memory/:memoryId
/timeline/edit-memory/:memoryId/location
/timeline/memories/:memoryId
/map
/map/memories/:memoryId
/letters
/letters/:letterId
```

The bottom tab bar is shown only on tab root routes:

- `/home`
- `/timeline`
- `/map`
- `/letters`

Detail/form routes hide the tab bar.

## Current UI/UX Direction

The visual language is based on the design tokens:

- Warm paper background.
- White cards with subtle border/shadow.
- Rose primary accent.
- Teal, moss, amber, lavender support colors.
- 8px card radius.
- Pill buttons/chips.
- Georgia-style display typography and simple sans body.

Important recent UI fix:

- Bottom sheets now use `AppColors.paper` background with rounded top corners through `bottomSheetTheme`.
- Previously they were transparent.
- User-facing UI copy is routed through Flutter gen-l10n with Vietnamese ARB as the current template.
- `AppFilterChip` shrink-wraps to text, so tag chips behave like flexbox items instead of stretching full width.

## Current Screens

Implemented screens:

- Opening Gift
- Home
- Time
- Add/Edit Memory
- Memory Detail
- Map
- Letters
- Letter Detail
- Recap

## Time Module Current State

The Time module has been upgraded from a static JSON timeline into an editable memory management area.

Current Time capabilities:

- Shows visible memories only.
- Supports dynamic tags.
- Always has `Tất cả` filter.
- Tag chips size to their content and wrap horizontally like a flexbox row.
- Memory cards show:
  - Cover thumbnail.
  - Title.
  - Date/place.
  - Short story.
  - Tag pill.
  - Media summary, for example `8 ảnh · 2 video · 1 lời nhắn`.
  - More/action menu.
- Empty state when no memory exists.
- Empty state when selected tag has no memory.
- Add memory route.
- Edit memory route.
- Soft delete memory.
- Set memory as featured.

## Add/Edit Memory Current State

Screen:

- `MemoryFormScreen`

Main sections:

- Main info card:
  - Title.
  - Description.
  - Date.
  - Location as a tappable Location Picker entry, not a free-text field.
  - Private note.
  - `Lời nhắn cho khoảnh khắc này`.

- Tag selector:
  - Uses wrap/flex behavior.
  - Each chip sizes to text.
  - Chips flow horizontally and wrap to the next line.
  - Supports creating custom tag.
  - The create-tag bottom sheet owns its `TextEditingController` inside a stateful sheet to avoid controller-after-dispose errors when dismissed.

- Media groups:
  - Dynamic groups.
  - MVP max: 3 groups per memory.
  - Each group has optional note.
  - Each group can contain images/videos mixed.
  - Add media source sheet exists.
  - Remove media item.
  - Remove group.
  - Move group up/down.

Validation:

- Title is required.
- Date is required.
- At least one body element is required:
  - description,
  - note,
  - voice message,
  - image,
  - video.

Previous location limitation (resolved):

- `Memory` already has `locationName`, `latitude`, `longitude`, and `placeId` fields.
- `MemoryDraft` previously carried only `locationName`.
- Add/Edit Memory now opens Location Picker and carries either an existing `locationId` or a new `MemoryLocationDraft` until memory save.

## Map Module Current State

The approved Map/Memory Location redesign is now implemented. The previous Map search implementation is retained below only as migration history.

### Previous Implementation (Removed)

- Uses `google_maps_flutter` for the map SDK.
- Uses Google Places Web Service through `http` for place search.
- Keeps map/search infrastructure layered:
  - `core/config/MapServiceConfig`
  - `domain/entities/place_search.dart`
  - `domain/repositories/place_search_repository.dart`
  - `data/data_sources/google_places_data_source.dart`
  - `data/repositories/place_search_repository_impl.dart`
  - `application/providers/map_providers.dart`
  - `application/state/map_search_controller.dart`
- Shows saved places from `assets/data/places.json` as map markers.
- Tapping a saved marker opens the existing `PlacePreviewSheet`.
- The saved places rail can recenter the map and open a place preview.
- Search uses Places Autocomplete with a session token and a bias around the saved places.
- Selecting a search suggestion fetches Place Details, drops a temporary marker, and moves the camera to the result.
- Search result selection is currently exploratory only; it is not yet persisted as a `Place` or attached to a memory.

This implementation has been removed from the Map UI. `places.json` remains only as an empty legacy-compatible asset.

### Implemented Target

Design source:

- [Figma - Love Journal Map + Memory Location](https://www.figma.com/design/b3zJU0jnS7ZFAaJNX6G5lC)

Approved behavior:

- Location is optional and is selected while creating or editing a memory.
- Tapping the Location area opens a dedicated Location Picker.
- The user can reuse an existing memory location, search a new geographic result with Google Places, or pin a coordinate manually.
- Selecting a Google suggestion fetches Place Details only at that point.
- The user can drag the map to refine the coordinate after search or use manual pinning as a fallback.
- The final display name is user-controlled. The Google place name is only an initial suggestion.
- A new location is committed together with the memory, not immediately when it is picked.
- Map tab is read-only: it has no search, add, edit, or standalone place management action.
- Map markers are projected from visible memories with valid locations.
- Memories sharing one internal `locationId` are grouped under one marker.
- Tapping a marker opens a warm bottom sheet listing the visible memories at that location; tapping a memory opens Memory Detail.
- Memories without location are omitted. Soft-deleted memories do not contribute to markers or counts.
- If no visible memory has a location, Map shows an emotional, actionable empty state that sends the user to Time/Add Memory.
- If no platform Maps key is configured, Map keeps a clear non-crashing fallback state.

Synchronization rules:

- Creating a memory with a location adds or updates the corresponding Map marker.
- Editing a memory location moves the memory between marker groups.
- Removing a memory location removes that memory from Map.
- Soft-deleting the last visible memory at a location removes the marker.
- Canceling Location Picker or abandoning the memory form must not create an orphan location.

Map API key configuration:

- Android package/application id: `vn.hung.le.lovejournal`.
- iOS bundle id: `vn.hung.le.lovejournal`.
- Android native map rendering reads `GOOGLE_MAPS_ANDROID_API_KEY` from a Gradle property, environment variable, or ignored `android/local.properties`, then injects it into the manifest placeholder.
- iOS native map rendering reads `GOOGLE_MAPS_IOS_API_KEY` from `ios/Flutter/Secrets.xcconfig`, which feeds `Info.plist` through `$(GOOGLE_MAPS_IOS_API_KEY)`.
- Dart/Places search can read the native key through the `love_journal/maps_config` platform channel as a temporary local-first path. For production, move Places calls behind a backend/proxy and keep the Places key server-side.
- Direct Android Places REST requests include `X-Android-Package` and the runtime signing certificate SHA-1 in `X-Android-Cert` without delimiters. Direct iOS requests include `X-Ios-Bundle-Identifier`.
- The Google Cloud project must enable `Places API (New)` and include it in the key's API restrictions; enabling only the platform Maps SDK is not enough for autocomplete.
- Restrict Android keys in Google Cloud to package `vn.hung.le.lovejournal` plus the signing certificate SHA-1. Restrict iOS keys to bundle id `vn.hung.le.lovejournal`.
- Do not commit real API keys.

Current Google Places blocker:

- Android Maps rendering can use the configured key path, but Location Picker autocomplete is still blocked by Google Cloud permissions in the current local setup.
- A direct Places API (New) autocomplete request was tested with the configured Android key, package `vn.hung.le.lovejournal`, and debug signing SHA-1 `9A:27:5D:11:3E:A1:38:DC:CC:25:39:D8:D3:7E:00:A1:94:34:5F:A0`.
- The direct request returned HTTP `403` / `PERMISSION_DENIED` from Google, which means the app request path reaches Google but the key/project/restriction/billing configuration is still not accepted by Google Cloud.
- The same key against the legacy Places endpoint returned `REQUEST_DENIED` because the legacy API is not enabled; this is expected because the app uses Places API (New).
- Do not solve this by moving search back to the Map tab or by hardcoding places. Keep the current Location Picker architecture and resolve the Google Cloud configuration or move Places requests behind a backend/proxy.

Fallback behavior:

- If no platform key is configured, Map shows the warm static fallback canvas plus an API-key empty state.
- This keeps local tests and development builds from crashing before secrets are configured.

## Important Data Model Decisions

`MemoryCategory` still exists for backward compatibility with seed JSON.

Newer editable model concepts:

- `MemoryTag`
  - Dynamic tag model.
  - System tags are created from old categories.
  - Custom tags can be created by user.

- `MemoryVoiceMessage`
  - Used for `Lời nhắn cho khoảnh khắc này`.
  - Can be `imported` or `recorded`.

- `MemoryMediaGroup`
  - A story segment.
  - Has optional note.
  - Holds mixed image/video items.
  - Has `sortOrder`.

- `deletedAt`
  - Used for soft delete.

Current location model:

- `MemoryLocation`
  - Immutable location entity/value used by memories.
  - Has a stable internal `id`, user-controlled `displayName`, optional `formattedAddress`, coordinates, optional `googlePlaceId`, and source `googlePlaces` or `manual`.
- `Memory.locationId`
  - References the internal location identity used to group Map markers.
- `googlePlaceId`
  - Identifies the external Google result and helps avoid duplicate locations.
  - It is not the Map grouping key and is optional for manually pinned locations.
- Location note ownership
  - There is no separate location note in the approved MVP.
  - The existing private `Memory.note` stays attached to the memory.

Legacy location compatibility:

- Current flat fields `locationName`, `latitude`, `longitude`, and `placeId` remain readable during migration.
- Current `placeId` values refer to bundled seed `Place` records and must not be interpreted automatically as Google Place IDs.
- `JournalData.places`, `Place`, `PlaceDto`, and `assets/data/places.json` remain for legacy compatibility, but `places.json` is now empty.
- After migration, persisted locations are created/reused through memory editing, while Map derives its visible marker projection from memories plus their referenced locations.

Current `Memory` supports both old and new fields:

- old fields:
  - `category`
  - `media`
  - `story`
  - `voiceNoteUrl`

- new fields:
  - `primaryTagId`
  - `note`
  - `voiceMessages`
  - `mediaGroups`
  - `deletedAt`

## Local Persistence

Current local persistence uses SharedPreferences.

Session preferences:

- `hasSeenOpening`
- `openedLetterIds`
- `favoriteMemoryIds`
- `lastViewedMemoryId`

Editable journal draft:

- Key: `journalDataDraft.v2`
- Codec: `JournalDataDraftCodec`
- Stores:
  - memories,
  - tags,
  - soft-deleted state,
  - voice message metadata,
  - media groups.
  - `MemoryLocation` records and memory `locationId` references.

Current persistence behavior:

- Persist `MemoryLocation` records and each memory's optional `locationId` in draft schema v2.
- Commit a newly picked location atomically with the memory save.
- Do not persist temporary autocomplete suggestions or a canceled manual pin.

Bundled editable seed state:

- `assets/data/memories.json` is `[]`.
- `assets/data/places.json` is `[]`.
- Memories and locations are created by the user from an empty state.
- Draft v1 is intentionally ignored so the removed hardcoded seed data does not reappear from SharedPreferences.

This is enough for MVP local-first editing, but should later be replaced by a real local database such as Drift, Isar, or SQLite before cloud sync.

## Current Mocked Areas

The following UI flows exist but are not native-real yet:

- Choosing audio from device.
- Recording audio.
- Choosing image/video from library.
- Capturing photo/video with camera.
- Real media playback.
- Real video thumbnails.
- Search in Time.

Current behavior:

- Audio/image/video actions create mock attachments.
- Mock media uses `AppAssets.heroImage`.
- Mock audio uses `mock://...` URIs.

Future native plugins likely needed:

- `file_picker` for audio import.
- `record` or similar for audio recording.
- `image_picker` or `photo_manager` for image/video picking.
- Permission handling for microphone, photos, camera.
- A backend/proxy for production-grade Google Places calls if API key protection becomes stricter than mobile key restrictions.

## Known Product Decisions

Decisions already made:

- Use Riverpod.
- Use immutable state models.
- Use GoRouter.
- Keep first version local-first.
- Keep API/repository abstraction even while data comes from JSON.
- Use soft delete for memories.
- Use dynamic tags instead of relying only on enum categories.
- Keep system tag labels localized at the presentation layer; domain/data keeps stable enum/tag IDs.
- Limit media groups to 3 per memory for MVP.
- Use `Lời nhắn cho khoảnh khắc này` instead of a separate generic `Audio` field.
- Keep user-facing UI copy in localization resources instead of hardcoded widget strings.
- Keep design aligned with `docs/designs`, not generic mobile mockups.
- Use Google Maps + Google Places for the first real Map implementation; keep the API key out of Git and provide a static fallback when the key is absent.
- Location is owned by the Add/Edit Memory flow; there is no standalone add-place flow in Map.
- Google Places Autocomplete exists only in Location Picker.
- Map is a read-only projection of visible memories with locations.
- Use an internal `locationId` for memory references and Map grouping; keep `googlePlaceId` optional external metadata.
- Let users choose the display name even when Google Places supplied the coordinate and address.
- Keep private notes attached to memories, not locations, for this milestone.

## Quality/Verification Status

Recent checks after implementing the Time editable module:

- `flutter analyze`: passed.
- `flutter test --no-pub`: passed.
- `flutter build apk --debug --no-pub`: passed.

After bottom sheet/theme and tag selector tweaks:

- `flutter analyze`: passed.

After adding Flutter localization, flex-style tag chips, and fixing create-tag sheet controller lifecycle:

- `flutter pub get`: passed.
- `flutter analyze`: passed.
- `flutter test`: passed.

After implementing real Map + Places search:

- `flutter pub get`: dependency resolution and l10n generation completed, but the command exited with a Windows symlink/Developer Mode warning while creating plugin symlinks.
- `flutter analyze`: passed.
- `flutter test`: passed.

After implementing Memory-owned locations and read-only Map projection:

- `flutter analyze`: passed.
- `flutter test --no-pub`: passed.
- `flutter build apk --debug --no-pub`: passed.
- Android debug package/SHA-1 used for API key restriction: `vn.hung.le.lovejournal` / `9A:27:5D:11:3E:A1:38:DC:CC:25:39:D8:D3:7E:00:A1:94:34:5F:A0`.
- Runtime Places autocomplete remains blocked by Google Cloud with HTTP `403 PERMISSION_DENIED` even after uninstalling the app, `flutter clean`, `flutter pub get`, and rebuilding locally.

## Environment Notes

The project is on Windows:

```txt
D:\Flutter\projects\flutter_love_journal
```

Flutter SDK is under:

```txt
D:\Flutter\flutter
```

The machine previously had cache/path issues after moving Flutter from `C:` to `D:`.

Useful local env vars:

```powershell
[Environment]::SetEnvironmentVariable('PUB_CACHE','D:\Flutter\pub-cache','User')
[Environment]::SetEnvironmentVariable('GRADLE_USER_HOME','D:\Flutter\gradle-cache','User')
```

Codex sometimes needs temporary env vars to avoid writing Dart analytics to blocked AppData:

```powershell
$env:APPDATA='D:\Flutter\projects\flutter_love_journal\.codex_tool_env\appdata'
$env:LOCALAPPDATA='D:\Flutter\projects\flutter_love_journal\.codex_tool_env\localappdata'
$env:PUB_CACHE='D:\Flutter\pub-cache'
```

Flutter commands may need elevated access because the Flutter SDK lockfile is outside the workspace.

Google Maps plugin note on Windows:

- Running `flutter pub get` after adding Flutter plugins may require Windows Developer Mode for symlink support.
- If `flutter pub get` exits with `Building with plugins requires symlink support`, enable Developer Mode in Windows Settings, then run `flutter pub get` again.

Map API key examples:

```powershell
# Android local development: put this in ignored android/local.properties.
GOOGLE_MAPS_ANDROID_API_KEY=your_android_restricted_key
```

```text
// iOS local development: copy ios/Flutter/Secrets.xcconfig.example to
// ios/Flutter/Secrets.xcconfig, then set:
GOOGLE_MAPS_IOS_API_KEY=your_ios_restricted_key
```

## Commands

Install dependencies:

```powershell
flutter pub get
```

Analyze:

```powershell
flutter analyze
```

Test:

```powershell
flutter test
```

Debug APK build:

```powershell
flutter build apk --debug
```

## Recommended Next Steps

Short-term:

1. Resolve Google Cloud Places `403 PERMISSION_DENIED` for the current Android key, or move Places calls to a backend/proxy earlier than planned.
2. Manually run Time/Add/Edit Memory/Location Picker/Map on Android and iOS with and without a platform Maps key after Places permission is fixed.
3. Add more widget/controller tests for:
   - Time empty state.
   - Add memory.
   - Create custom tag.
   - Soft delete memory.
   - Location Picker cancel does not persist a location.
   - Reusing a location groups memories under one marker.
   - Moving/removing/soft-deleting a memory updates Map projection.
   - Map and Location Picker missing-key states.
4. Add localization coverage for new Location Picker and Map copy.
5. Replace mock media/audio with native picker/recorder behind small service abstractions.

Medium-term:

1. Move editable data from SharedPreferences draft JSON to a local database.
2. Add search in Time.
3. Add undo or trash for soft-deleted memories.
4. Add real media preview/playback.
5. Add permission handling UX.
6. Move Places Web Service calls behind a backend/proxy before production if mobile restrictions are insufficient.

Long-term:

1. Add account system.
2. Add partner invite and couple space.
3. Add cloud database and media storage.
4. Add sync/conflict resolution.
5. Add messaging, stickers, video call, and watch-together journal playback.

## Important Caution For Future Work

Do not remove the repository/data-source abstraction just because the app currently reads JSON. That separation is intentional and should remain.

Do not convert the app back to simple `setState`-only architecture. Local widget state is fine for forms, but app/domain state should stay in Riverpod controllers.

Do not treat Time as a photo gallery. The core object is still a written memory with emotional structure; media is supporting material.

Do not add place creation, search, or editing back into the Map tab. The approved ownership flow is Add/Edit Memory -> Location Picker -> saved memory -> read-only Map projection.

Do not treat the current `places.json` list as product-owned location data. It is legacy seed data that must be migrated or replaced without breaking existing memories.
