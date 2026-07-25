# Current Context - Flutter Love Journal

Last updated: 2026-07-25

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
- A stage-1 Home "Nhật ký sống" experience with a scrapbook hero, real journal stats, recent-memory discovery carousel, compact letter section, recap band, and reduced-motion support.
- Android application id and iOS bundle id are `vn.hung.le.lovejournal`.

The current codebase is still local-first. Native image/video picking and voice recording are implemented, but there is no auth, partner invite, cloud sync, cloud media storage, or backend yet.

## Important Project Files

Design and product context:

- `docs/designs/love-journal-implementation-spec.md`
- `docs/designs/love-journal-current-ui-ux.md`
- `docs/designs/love-journal-design-tokens.json`
- `docs/designs/love-journal-figma-handoff.html`
- `docs/designs/love-journal-home-living-journal-handoff.html`
- `docs/designs/love-journal-home-living-journal-preview.png`
- `docs/designs/love-journal-memory-composer-handoff.html`
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
  - Uses Places API (New) REST through the platform-neutral `GooglePlacesApiDataSource`, including on Android during local-first development.
  - Keeps the data-source boundary so production can replace direct client calls with a backend/proxy without changing controllers or UI.
  - It is consumed only by Location Picker.

- `locationSearchControllerProvider`
  - Holds immutable Location Picker state for autocomplete, Nearby Search candidates, selected Place Details, transient photo bytes, and independent loading/error states.
  - Uses request generations so a slower result from an older map tap cannot overwrite the latest selection.

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

## Home Module Current State

Home has been redesigned from a summary dashboard into the stage-1 "Nhật ký sống" experience.

Implemented Home behavior:

- Header uses `Chào em` / `Mình & Em`; the heart action opens Recap.
- The 334px living hero uses the featured memory, or the first visible memory when none is explicitly featured.
- The hero shows the love-day count, memory title, date, and location.
- An image cover renders directly; a video cover renders its static thumbnail and does not initialize playback.
- The stats ribbon shows love days, visible memory count, and the number of unique valid Map location groups from `JournalData.mapLocationGroups`.
- `Những mảnh ghép` is a PageView of up to five newest memories, excluding the hero memory and revealing part of the next card.
- Tapping a discovery card opens Memory Detail.
- The compact letter section uses the current pinned/next letter and preserves locked/opened state copy.
- The Recap band and hero both open Recap.
- When no memory exists, Home uses the anniversary fallback image, hides the discovery carousel, and shows `Tạo kỷ niệm đầu tiên`, routed to `/timeline/new-memory`.
- Header, hero, stats, and lower sections use one short staggered entrance animation.
- Carousel cards scale slightly by page distance.
- When `MediaQuery.disableAnimations` is enabled, entrance content appears immediately and PageView scaling is disabled.

Home stage 2 is intentionally deferred:

- daily-memory selection;
- hero parallax;
- animated count-up stats;
- featured-memory priority inside the discovery carousel;
- muted video autoplay with route/tab lifecycle handling.

Approved visual handoff:

- `docs/designs/love-journal-home-living-journal-handoff.html`
- `docs/designs/love-journal-home-living-journal-preview.png`

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

Current experience:

- Add/Edit is a visual `Memory Composer`, not a long detail form.
- The empty canvas starts with three equal entry points:
  - image/video;
  - write one line;
  - voice message.
- Date, primary tag, and optional location live in compact metadata chips.
- Date opens a fixed 42-cell month sheet; previous/next month changes are direct state updates without the default Material date-picker transition.
- The title is generated from the first story line, location, or tag/date and remains editable from the header.
- Description and legacy private note are merged into one story field when an old memory is edited.
- `Lời nhắn cho khoảnh khắc này` supports importing audio or recording with the device microphone.
- Images/videos use native device pickers and are copied into the app documents directory before entering the draft.
- Video selection supports multi-select with a hard limit of 3 videos across the whole memory.
- A blocking warm loading overlay appears while selected videos are prepared/copied; multiple files show the current `x/n` item, and selections beyond the remaining slots are skipped with feedback.
- Every imported video generates a static first-frame JPEG thumbnail. Each media item stores its own `thumbnailUri`, so multiple videos in one segment render independently without keeping several video decoders alive.
- Tapping an image or video opens a full-screen, swipeable viewer without leaving or discarding the composer draft.
- Media groups remain dynamic, mixed image/video, sortable, and limited to 3.
- Every media group has an editable title plus an optional note; legacy groups without a stored title fall back to `Đoạn x`.
- Voice messages are limited to 3.
- A selected location can be changed through Location Picker or removed directly from its metadata chip.
- Saving opens the resulting Memory Detail instead of only popping the route.

State and persistence:

- `MemoryComposerDraft` is immutable and serialized independently from the journal data draft.
- `MemoryComposerController` is a Riverpod family controller keyed by new/edit memory draft id.
- Composer changes debounce-save to SharedPreferences and flush immediately when the close/back action occurs.
- Reopening offers to resume or discard a meaningful local draft.
- Successful submit cancels pending autosave and deletes the composer draft.

Validation:

- Title is generated automatically when the user does not override it.
- At least one body element is required:
  - story,
  - voice message,
  - image,
  - video.
- Date and the default `Đời thường` tag are preselected.
- Location alone is not meaningful content.

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
- The user can reuse an existing memory location, search a new geographic result with Google Places, or select a coordinate directly on the map.
- The map starts in browse mode. A compact segmented control switches between `Xem` and `Chọn vị trí`; the reset icon appears separately only when a marker exists.
- The toolbar contains no long status sentence. Browse/select instructions are shown in the contextual bottom panel.
- Pan/zoom never changes the selected coordinate and never starts a Places request.
- A map tap or marker drag-end creates a temporary manual marker and runs Nearby Search within 150 meters, ranked by distance, with at most 8 candidates.
- Nearby candidates appear as tappable map markers and as a mirrored list for dense areas and accessibility.
- Selecting an Autocomplete suggestion or Nearby candidate fetches compact Place Details only at that point.
- The selected-place preview can show one transient Google photo, place type, address, business status, attribution, and a Google Maps link.
- If Nearby Search is empty or fails, the manual coordinate remains usable.
- Focusing Google Places Search hides the contextual bottom panel immediately, before keyboard insets animate. The search/map step does not resize its Stack for the keyboard, so the input and suggestions remain anchored at the top.
- Dismissing the keyboard restores the same bottom-panel content without clearing the selected place, marker, photo, query, or draft. Choose and Name steps retain normal keyboard resize/scroll behavior.
- The final display name is user-controlled. The Google place name is only an initial suggestion.
- A new location is committed together with the memory, not immediately when it is picked.
- Map tab is read-only: it has no search, add, edit, or standalone place management action.
- Map markers are projected from visible memories with valid locations.
- Memories sharing one internal `locationId` are grouped under one marker.
- Tapping a marker opens a warm bottom sheet listing the visible memories at that location; tapping a memory opens Memory Detail.
- The marker sheet is presented on the root navigator so its surface and modal barrier stay above the persistent bottom tab bar.
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
- Location Picker calls Places API (New) REST through `GooglePlacesApiDataSource` on Android and the other currently supported clients.
- The Dart repository contract remains platform-neutral so the direct REST implementation can be replaced by a backend/proxy later.
- Autocomplete uses a 50,000 meter circular location bias and reuses one session token through Place Details.
- Nearby Search uses a 150 meter circle, returns at most 8 candidates, requests all place types, and ranks by distance.
- Nearby Search has no Autocomplete session token. Place Details receives a session token only when it completes an Autocomplete selection.
- Place Details requests compact Pro fields. The first photo is fetched lazily only after selection and is not persisted.
- Map camera movement is local UI behavior; only map tap and marker drag-end trigger Nearby Search.
- The Google Cloud project must enable `Places API (New)` and include it in the key's API restrictions; enabling only the platform Maps SDK is not enough for autocomplete.
- Places Web Service does not support Android/iOS application restrictions. The direct client REST key is temporarily unrestricted by application for local development and must be limited by API restriction to the required Maps/Places services.
- Production must not ship an unrestricted Places Web Service key. Move Places calls behind a backend/proxy, and use a separate Android-restricted key for native Maps rendering.
- Do not commit real API keys.

Google Places diagnostics and temporary resolution:

- The former Android implementation called Places API (New) REST directly with an Android-restricted key and received HTTP `403 PERMISSION_DENIED` even with correct package/certificate headers.
- A native Places SDK for Android bridge was then tested but returned SDK status `9011 REQUEST_DENIED` on-device.
- Cloud checks confirmed `billingEnabled: true`, active billing, both `places.googleapis.com` and `maps-android-backend.googleapis.com`, and that the key belongs to project `love-journal-map`.
- A direct Places REST Autocomplete request from Google Cloud Shell returned suggestions with the same unrestricted key, while identical requests from the local Windows host and Android device returned HTTP `403 PERMISSION_DENIED`.
- `gcloud services api-keys describe` confirms this is a standard API key with no application restriction and only `places.googleapis.com` plus `maps-android-backend.googleapis.com` API targets. The linked payments profile country is Vietnam.
- Payload isolation confirmed that field mask, query length, session token, and location bias are not the cause; even the minimal request fails outside Cloud Shell. Forced IPv4 and IPv6 requests from the local Windows host both return `403`, so the denial is not specific to one IP protocol. Android keeps the REST path for transparent diagnostics while local egress/Google edge behavior is investigated.
- Local Windows diagnostics show direct WinHTTP access, no environment/browser proxy, no Google hosts-file override, Google-owned DNS answers, Vietnam egress classification, and Cloudflare WARP off. Recreating more keys in the same project is therefore lower value than testing another physical network and an isolated project.
- The recurring `Regional Access Boundary` / `Gaia id not found` warning appears before otherwise successful `gcloud` commands and is tracked separately as a Cloud CLI identity-lookup warning; it is not currently treated as proof of the Places denial.
- REST requests intentionally omit `X-Android-Package`, `X-Android-Cert`, and iOS bundle headers because mobile application restrictions are not supported by Places Web Service.
- Do not solve Places failures by moving search back to Map or reintroducing hardcoded places.
- On 2026-07-21, a replacement local key associated with a different Maps/billing setup returned HTTP `200` with five Autocomplete suggestions from the same Windows host. A debug APK then built successfully with the replacement key injected into the merged Android manifest.
- This proves the Flutter REST request path is functional, but it does not establish production eligibility. Google's current Maps Platform Prohibited Territories list includes Vietnam even though the coverage table shows map data for Vietnam.
- Cloud Billing country must match the real billing mailing address. Selecting a false country is not an acceptable production workaround; distribution in Vietnam requires a compliance decision and likely a provider strategy that is permitted for the target market.

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
  - Has an optional editable title with `Đoạn x` as the legacy/null UI fallback.
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

## Native And Incomplete Boundaries

Native-real now:

- Image selection and camera capture through `image_picker`.
- Multi-video selection through `file_picker`, limited to the remaining slots within the 3-video-per-memory rule.
- Audio-file import through `file_picker`.
- Voice recording through `record`.
- Picked files are copied to app-owned storage before draft persistence.
- Static first-frame video thumbnails through `video_thumbnail_gen`; image/video playback through `video_player` only when playback is requested.
- Full-screen image/video viewer from both Composer and Memory Detail.
- A video selected as the Memory Detail cover auto-plays for at most 3 completed runs, then stops; later user-initiated plays run once without automatic replay or seeking.

Still incomplete:

- Real audio playback controls; the current player is visual only.
- Dedicated permission-denied/settings UX beyond the system prompt and inline error.
- Cleanup policy for unreferenced attachment files.
- Search in Time.

Future infrastructure still needed:

- Cloud object storage/upload and attachment sync.
- Media transcoding, cloud thumbnail variants, and long-term cache lifecycle.
- A backend/proxy for production-grade Google Places calls; Places Web Service cannot safely use mobile application restrictions from a shipped client.

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
- Location Picker map selection is an explicit toggle mode; browsing the camera must never mutate the draft.
- The map mode toggle is the compact `Xem` / `Chọn vị trí` segmented control. Keep explanatory copy in the bottom context panel, not beside the control.
- Search focus temporarily hides the bottom context panel and the search/map Stack does not resize for the keyboard; dismissing the keyboard restores the existing selection.
- A deliberate map tap or marker drag-end may use Nearby Search to resolve Google places around the selected coordinate.
- Google place photos and business metadata are transient picker data, not persisted journal fields.
- Map is a read-only projection of visible memories with locations.
- Use an internal `locationId` for memory references and Map grouping; keep `googlePlaceId` optional external metadata.
- Let users choose the display name even when Google Places supplied the coordinate and address.
- Keep private notes attached to memories, not locations, for this milestone.
- Generate and persist one first-frame JPEG thumbnail per imported video. Store its app-owned path in `MemoryMedia.thumbnailUri`; legacy media without that field uses runtime thumbnail extraction as a fallback.
- Keep video playback controls to play/pause only. Cover video may auto-play 3 times; viewer videos play once per opened playback cycle.
- Limit each memory to 3 video attachments. Enforce the rule in both the picker flow and `MemoryComposerController`, and show a modal loading state while large files are copied into app-owned storage.

## Quality/Verification Status

After implementing Home "Nhật ký sống" stage 1:

- Home widget tests cover 320, 393, and 430 logical pixel widths, large text scale, empty/one/many memory states, hero/recap interaction, recent-memory navigation, empty Add Memory CTA, static video thumbnail behavior, and Reduce Motion.
- `flutter analyze`: passed.
- `flutter test --no-pub`: passed, 36 tests.
- `flutter build apk --debug --no-pub`: passed.
- Android build currently emits a non-blocking future-compatibility warning because `file_picker` still applies Kotlin Gradle Plugin instead of Flutter's Built-in Kotlin flow.

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
- Android debug restriction identity retained for native Maps and future production key setup: `vn.hung.le.lovejournal` / `9A:27:5D:11:3E:A1:38:DC:CC:25:39:D8:D3:7E:00:A1:94:34:5F:A0`.
- The native Places bridge was removed after on-device `9011 REQUEST_DENIED`; the old key succeeded only from Cloud Shell and was denied from the local host/device.
- REST data-source tests cover the supported authentication headers. The replacement key now succeeds from Windows; on-device Autocomplete/Place Details still needs a fresh runtime verification.

After implementing Memory Composer:

- `flutter pub get`: passed.
- `flutter analyze --no-pub`: passed with no issues.
- `flutter test --no-pub`: all tests passed.
- `flutter build apk --debug --no-pub`: passed.
- `flutter build web --no-pub`: passed, including Wasm dry run.
- Android emits a forward-looking KGP warning for `file_picker 10.x`; 10.x is intentionally pinned while this AGP 9 project remains on the Flutter template's Built-in Kotlin opt-out.

After implementing video thumbnails, media viewer, and cover playback:

- `flutter pub get`: passed; `video_player 2.13.0` and platform implementations resolved.
- `flutter analyze`: passed with no issues.
- `flutter test --no-pub`: all 9 tests passed, including the 3-play cover replay policy.
- `flutter build apk --debug --no-pub`: passed.
- Android `minSdk` is now 24, matching the supported Android baseline for the selected `video_player` version.

After adding multi-video import progress and the 3-video limit:

- `flutter analyze`: passed with no issues.
- `flutter test --no-pub`: all 12 tests passed, including batch limiting and loading-overlay coverage.
- `flutter build apk --debug --no-pub`: passed.

After replacing live tile decoders with per-video static thumbnails:

- `flutter pub get`: passed; `video_thumbnail_gen 0.6.3` resolved.
- `flutter analyze`: passed with no issues.
- `flutter test --no-pub`: all 12 tests passed, including `thumbnailUri` draft-codec round-trip coverage.
- `flutter build apk --debug --no-pub`: passed with AGP 9; the existing `file_picker` Built-in Kotlin warning remains.

After compacting the Location Picker toolbar and fixing keyboard overlap:

- `flutter analyze`: passed with no issues.
- `flutter test --no-pub`: all 24 tests passed.
- Toolbar widget tests cover 320, 360, and 430 logical pixels plus 200% text scale.
- Focus tests cover immediate bottom-panel hiding and restoration without losing the existing selection.
- `flutter build apk --debug --no-pub`: passed; the existing `file_picker` Built-in Kotlin warning remains.

After moving the Map marker sheet above the navigation shell:

- The root-overlay regression test confirms the shell tab bar cannot receive taps through `LocationMemoryListSheet`.
- `flutter analyze`, the full test suite, and Android debug build pass.

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
# Direct Places REST currently requires Application restriction=None.
GOOGLE_MAPS_ANDROID_API_KEY=your_local_maps_and_places_key
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

1. Reinstall/run the newly built debug APK and verify Autocomplete, Place Details, manual pinning, memory save, and read-only Map projection on Android.
2. Decide on a production-compliant map/search provider strategy for distribution in Vietnam; do not treat a mismatched billing country as the production solution.
3. Add more widget/controller tests for:
   - Time empty state.
   - Add memory.
   - Create custom tag.
   - Soft delete memory.
   - Location Picker cancel does not persist a location.
   - Reusing a location groups memories under one marker.
   - Moving/removing/soft-deleting a memory updates Map projection.
   - Map and Location Picker missing-key states.
4. Audit localization coverage whenever new Composer, Location Picker, Map, or media error copy is added.
5. Add real audio playback, list-card video thumbnail polish, and cleanup for unreferenced attachment files.

Medium-term:

1. Move editable data from SharedPreferences draft JSON to a local database.
2. Add search in Time.
3. Add undo or trash for soft-deleted memories.
4. Add media preloading/cache policy and richer failure recovery for large or unreadable local files.
5. Add permission handling UX.
6. Move all Places Web Service calls behind a backend/proxy before production and restore an Android package/SHA-1-restricted key for native Maps rendering.

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
