# Current Context - Flutter Love Journal

Last updated: 2026-07-04

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
- Local-first persistence for app session and editable journal draft.
- A redesigned and partially implemented Time module with add/edit/delete memory flow.

The current codebase is still local-first. There is no auth, partner invite, cloud sync, real media picker, real audio recorder, or backend yet.

## Important Project Files

Design and product context:

- `docs/designs/love-journal-implementation-spec.md`
- `docs/designs/love-journal-current-ui-ux.md`
- `docs/designs/love-journal-design-tokens.json`
- `docs/designs/love-journal-figma-handoff.html`
- `docs/designs/love-journal-time-management-handoff.html`
- `docs/current-context.md`

Main Flutter app:

- `lib/main.dart`
- `lib/src/app/love_journal_app.dart`
- `lib/src/app/router/app_router.dart`
- `lib/src/app/router/app_routes.dart`
- `lib/src/app/navigation/main_navigation_shell.dart`
- `lib/src/core/theme/app_theme.dart`
- `lib/src/core/theme/app_tokens.dart`

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
/timeline/edit-memory/:memoryId
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
  - Location.
  - Private note.
  - `Lời nhắn cho khoảnh khắc này`.

- Tag selector:
  - Uses wrap/flex behavior.
  - Each chip sizes to text.
  - Chips flow horizontally and wrap to the next line.
  - Supports creating custom tag.

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

- Key: `journalDataDraft.v1`
- Codec: `JournalDataDraftCodec`
- Stores:
  - memories,
  - tags,
  - soft-deleted state,
  - voice message metadata,
  - media groups.

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

## Known Product Decisions

Decisions already made:

- Use Riverpod.
- Use immutable state models.
- Use GoRouter.
- Keep first version local-first.
- Keep API/repository abstraction even while data comes from JSON.
- Use soft delete for memories.
- Use dynamic tags instead of relying only on enum categories.
- Limit media groups to 3 per memory for MVP.
- Use `Lời nhắn cho khoảnh khắc này` instead of a separate generic `Audio` field.
- Keep design aligned with `docs/designs`, not generic mobile mockups.

## Quality/Verification Status

Recent checks after implementing the Time editable module:

- `flutter analyze`: passed.
- `flutter test --no-pub`: passed.
- `flutter build apk --debug --no-pub`: passed.

After bottom sheet/theme and tag selector tweaks:

- `flutter analyze`: passed.

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

1. Manually run the app and inspect Time/Add/Edit Memory UI on a device/emulator.
2. Polish form spacing and any overflowing labels.
3. Add widget tests for:
   - Time empty state.
   - Add memory.
   - Create custom tag.
   - Soft delete memory.
4. Replace mock media/audio with native picker/recorder behind small service abstractions.

Medium-term:

1. Move editable data from SharedPreferences draft JSON to a local database.
2. Add search in Time.
3. Add undo or trash for soft-deleted memories.
4. Add real media preview/playback.
5. Add permission handling UX.

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
