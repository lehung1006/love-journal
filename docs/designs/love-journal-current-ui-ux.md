# Mình & Em - Current UI/UX Source Of Truth

Last updated: 2026-07-13
Implementation status: reflects the implemented Map/Memory Location flow, empty bundled memory/place seeds, and the current Google Places permission blocker.

## Purpose

This document describes both the UI/UX currently implemented by Flutter and any approved target behavior that is still pending native/backend work. Sections use these labels:

- **Implemented:** present in the current Flutter code.
- **Approved target:** reviewed in Figma and intended behavior when the remaining native/backend dependency is available.

Use this file when:

- continuing implementation on another device;
- checking whether the app still matches the design direction;
- planning the next UX iteration;
- deciding whether a new feature belongs in the current app surface.

Related design files:

- `love-journal-design-tokens.json`: design tokens.
- `love-journal-figma-handoff.html`: original MVP visual handoff.
- `love-journal-time-management-handoff.html`: Time/Add Memory extension handoff.
- `love-journal-implementation-spec.md`: product and implementation spec.
- [Figma - Love Journal Map + Memory Location](https://www.figma.com/design/b3zJU0jnS7ZFAaJNX6G5lC): approved Map and Location Picker flow.

## Product Feel

`Mình & Em` is a private couple journal. The current app should feel like a warm, intentional archive of shared memories, not a generic productivity tool and not a plain photo gallery.

Core UX principle:

> The memory is the emotional object. Media supports the memory.

The UI should stay:

- warm;
- private;
- readable;
- emotionally soft;
- structured enough to scale into a real product.

Avoid:

- generic social-media gallery patterns;
- overly busy dashboards;
- marketing-style landing pages inside the app;
- one-note color palettes;
- form screens that feel like admin CRUD.

## Visual System

Current visual language comes from `love-journal-design-tokens.json` and is implemented in:

- `lib/src/core/theme/app_tokens.dart`
- `lib/src/core/theme/app_theme.dart`
- `lib/l10n/app_vi.arb` for user-facing copy

Core values:

```txt
Base frame: 393 x 852
Screen horizontal padding: 20
Card radius: 8
Primary button height: 52
Secondary button height: 44
Icon button size: 40
Bottom tab bar height: 64
```

Primary colors:

```txt
Paper: #FFF8F2
Paper muted: #F4EBE4
Surface: #FFFFFF
Surface warm: #FFF4EE
Ink: #20191D
Muted: #75686F
Line: #E7D9CF
Rose: #BF5363
Rose dark: #923B4A
Teal: #3F7B84
Moss: #687F6F
Amber: #C5964F
Lavender: #87779D
Night: #19151D
```

Typography:

```txt
Display: Georgia or platform serif
Body: Inter or platform sans
Display XL: 44 / 44
Display L: 34 / 36
Title L: 26 / 29
Title M: 20 / 24
Body L: 16 / 24
Body M: 14 / 21
Body S: 12 / 16
Label: 11 / 14 uppercase
```

Current common styling:

- Warm page gradient background.
- White or warm white cards.
- Subtle border using `AppColors.line`.
- Soft shadows for cards and floating sheets.
- Pill buttons and filter chips.
- Filter chips shrink-wrap to their text and wrap like flexbox items when used in forms.
- Circular icon buttons.
- Bottom sheets with `AppColors.paper` background and rounded top corners.

Localization:

- User-facing app copy is routed through Flutter gen-l10n.
- Vietnamese is the current template locale in `lib/l10n/app_vi.arb`.
- Domain/data IDs, route names, JSON keys, asset paths, and mock URIs remain technical strings outside localization.

## Navigation UX

The app uses GoRouter with a `StatefulShellRoute.indexedStack`.

Bottom tabs:

```txt
Home
Time
Map
Thư
```

The bottom tab bar appears only on root tab screens:

```txt
/home
/timeline
/map
/letters
```

The tab bar is hidden on deeper routes:

```txt
/home/memories/:memoryId
/home/letters/:letterId
/home/recap
/timeline/new-memory
/timeline/edit-memory/:memoryId
/timeline/new-memory/location
/timeline/edit-memory/:memoryId/location
/timeline/memories/:memoryId
/map/memories/:memoryId
/letters/:letterId
```

Navigation diagram:

```mermaid
flowchart TD
  A["Opening Gate"] --> B["Main Tabs"]

  B --> H["Home"]
  B --> T["Time"]
  B --> M["Map"]
  B --> L["Thư"]

  H --> HD["Memory Detail"]
  H --> HR["Recap"]
  H --> HL["Letter Detail"]

  T --> TA["Add Memory"]
  T --> TE["Edit Memory"]
  T --> TD["Memory Detail"]
  TA --> LP["Location Picker"]
  TE --> LP

  M --> MS["Location Memory List Sheet"]
  MS --> MD["Memory Detail"]

  L --> LD["Letter Detail"]
```

## Global States

### Loading

Used while journal data or session preferences are loading.

Current UI:

- warm page scaffold;
- centered rose `CircularProgressIndicator`.

### Error

Used when journal data or session preferences fail.

Current UI:

- warm page scaffold;
- centered `EmptyStateCard`;
- title: `Chưa mở được nhật ký`;
- body: raw error text.

### Opening Gate

If `hasSeenOpening` is false, user is redirected to Opening Gift.

When CTA is tapped:

- `hasSeenOpening` is persisted;
- route navigates to Home.

## Screen: Opening Gift

File:

- `lib/src/features/journal/presentation/screens/opening_gift_screen.dart`

Purpose:

- make first launch feel like opening a private gift;
- establish emotional tone before utility surfaces appear.

Current UI:

- full-screen vertical hero image;
- dark photo overlay;
- safe-area aware content;
- kicker: `Gửi riêng em`;
- large serif title;
- short body copy;
- primary CTA: `Mở món quà`.

UX behavior:

- first launch only;
- CTA completes opening and navigates into Home.

Notes:

- The opening image currently uses `assets/images/anniversary-hero.png`.
- Later, replay can be added from Settings or debug menu.

## Screen: Home

File:

- `lib/src/features/journal/presentation/screens/home_screen.dart`

Purpose:

- emotional dashboard;
- first landing screen after opening;
- not a dense utility dashboard.

Current sections:

1. Top bar
   - kicker: `Chào em`;
   - title: `Mình & Em`;
   - heart icon leading to recap.

2. Hero memory card
   - image from featured memory or fallback hero image;
   - kicker: `Kỷ niệm của tụi mình`;
   - large love day count;
   - subtitle: `Và anh vẫn muốn đi tiếp cùng em.`

3. Stats row
   - number of visible memories;
   - number of places.

4. Featured memory
   - shows `MemoryListCard`;
   - if no visible memory exists, shows empty state:
     - `Chưa có kỷ niệm nổi bật`
     - `Khi thêm kỷ niệm đầu tiên, Home sẽ giữ lại khoảnh khắc đáng nhớ nhất ở đây.`

5. Next letter
   - shows pinned letter or first available letter;
   - empty state if no letter exists.

6. Recap CTA
   - primary button: `Xem recap ba năm`.

UX notes:

- Home now handles an empty memory list safely.
- Featured memory respects soft delete.
- Home still intentionally has one main emotional action: recap.

## Screen: Time

File:

- `lib/src/features/journal/presentation/screens/timeline_screen.dart`

Purpose:

- browse memories chronologically;
- create, edit, soft-delete, and feature memories;
- filter memories by dynamic tag.

Current top bar:

- kicker: `Theo dòng thời gian`;
- title: `Time`;
- search icon button;
- add memory icon button.

Search status:

- Search button exists.
- Search behavior is not implemented yet.

Tag filter UX:

- `Tất cả` is always first.
- Other tags come from `MemoryTag` data.
- Tags are dynamic, including user-created custom tags.
- System tag labels are localized in presentation based on stable system tag IDs.
- Selecting a chip filters the timeline in place.

List UX:

- Visible memories only.
- Soft-deleted memories are hidden.
- Timeline spine remains on the left.
- Memory cards animate with fade + slight vertical translate.

Memory card content:

- cover thumbnail;
- title;
- date/place;
- short story;
- tag pill;
- media summary, for example:
  - `8 ảnh · 2 video · 1 lời nhắn`;
- overflow menu.

Memory action sheet:

- title: memory title;
- helper: `Chọn cách chỉnh sửa kỷ niệm này.`;
- actions:
  - `Sửa kỷ niệm`;
  - `Đặt làm kỷ niệm nổi bật`;
  - `Xóa kỷ niệm`.

Delete UX:

- destructive action opens confirmation dialog;
- confirm soft-deletes memory using `deletedAt`;
- deleted memory disappears from Time and Home.

Empty state: no memories

- title: `Chưa có kỷ niệm nào được viết`;
- body: `Bắt đầu bằng một khoảnh khắc nhỏ. Một buổi tối bình thường cũng xứng đáng được giữ lại.`;
- CTA: `Thêm kỷ niệm đầu tiên`.

Empty state: selected tag has no memory

- title: `Chưa có kỷ niệm trong nhãn này`;
- body: `Bạn có thể thêm một kỷ niệm mới vào nhãn đang chọn.`;
- CTA: `Thêm vào nhãn này`.

UX flow:

```mermaid
flowchart TD
  A["Time tab"] --> B{"Có visible memories?"}
  B -->|"Không"| C["Empty State"]
  C --> D["Thêm kỷ niệm đầu tiên"]
  B -->|"Có"| E["Timeline list"]

  E --> F["Chọn tag"]
  F --> G{"Có memory trong tag?"}
  G -->|"Không"| H["Empty filtered state"]
  G -->|"Có"| E

  E --> I["Tap card"]
  I --> J["Memory Detail"]

  E --> K["Tap overflow"]
  K --> L["Action Sheet"]
  L --> M["Edit Memory"]
  L --> N["Feature Memory"]
  L --> O["Confirm Delete"]
```

## Screen: Add/Edit Memory

File:

- `lib/src/features/journal/presentation/screens/memory_form_screen.dart`

Routes:

- `/timeline/new-memory`
- `/timeline/edit-memory/:memoryId`

Approved child routes:

- `/timeline/new-memory/location`
- `/timeline/edit-memory/:memoryId/location`
- Location Picker is one pushed screen with internal UI states, not eleven separate routes.
- The bottom tab bar remains hidden while the picker is open.

Purpose:

- create or update one curated memory;
- keep form story-first;
- avoid becoming a generic file/media manager.

The bottom tab bar is hidden on this screen.

### App Bar

Current UI:

- back circular icon;
- centered title:
  - `Kỷ niệm mới`;
  - `Sửa kỷ niệm`;
- save circular icon;
- sticky bottom primary CTA:
  - `Lưu kỷ niệm`;
  - loading label: `Đang lưu...`.

### Main Info Card

Fields:

- `Tiêu đề`;
- `Mô tả`;
- `Thời gian`;
- `Địa điểm`;
- `Ghi chú`;
- `Lời nhắn cho khoảnh khắc này`.

Previous location behavior (removed):

- `Địa điểm` was a free-text field.
- The form saved `locationName` only and did not preserve coordinates or a stable location reference.

Current location behavior:

- Replace the free-text field with a tappable Location row/card.
- The empty state communicates that location is optional and offers `Thêm địa điểm`.
- A selected state shows the user-defined display name, address when available, and actions to change or remove the location.
- Tapping the row opens Location Picker and returns a temporary `MemoryLocation` selection to the form.
- The returned selection is committed only when the memory itself is saved.
- Canceling the picker or abandoning the form must not create an orphan location.

Validation:

- title is required;
- date is required;
- at least one meaningful body element must exist:
  - description,
  - note,
  - voice message,
  - image,
  - video.

Location does not satisfy the meaningful-body validation on its own.

### Location Picker - Current Implementation

Design source:

- [Figma - Love Journal Map + Memory Location](https://www.figma.com/design/b3zJU0jnS7ZFAaJNX6G5lC)

Purpose:

- attach optional geographic context to a memory;
- keep location creation inside the memory workflow;
- offer accurate Google search without forcing users to position every pin by hand;
- let the couple use their own emotional name for a place.

Approved design states:

1. `01 / Map empty`
   - no visible memory has a valid location;
   - Map shows an emotional empty state and CTA leading to Time/Add Memory.
2. `02 / Map from memories`
   - read-only map with markers projected from visible memories.
3. `03 / Place memory list`
   - marker bottom sheet lists all visible memories sharing the location.
4. `04 / Location empty`
   - Add/Edit Memory has no selected location yet.
5. `05 / Choose a location`
   - user chooses an existing location or starts a new search/manual pin flow.
6. `06 / Reuse existing place`
   - shows locations already referenced by memories and returns the selected internal `locationId`.
7. `07 / Google Places suggestions`
   - autocomplete suggestions appear after a short debounce;
   - results include Google attribution and a manual-pin fallback.
8. `08 / Search result selected`
   - Place Details supplies the exact coordinate, formatted address, and `googlePlaceId`;
   - user may drag the map to refine the pin before continuing.
9. `09 / Manual pin fallback`
   - user pans/zooms the map and places the coordinate without a Google result;
   - manual locations do not require `googlePlaceId`.
10. `10 / Name and save`
    - user confirms a required display name;
    - Google name may prefill the field but remains editable;
    - saving returns the selection to Add/Edit Memory, not directly to persistence.
11. `11 / Maps key unavailable`
    - explains that map/search is unavailable without a platform key;
    - app remains stable and allows cancel/back instead of crashing.

Location Picker flow:

```mermaid
flowchart TD
  A["Location field in Add/Edit Memory"] --> B{"Has selected location?"}
  B -->|"No"| C["Location empty"]
  B -->|"Yes"| D["Selected location card"]
  C --> E["Choose a location"]
  D --> E
  D --> R["Remove location"]
  E --> F["Reuse existing location"]
  E --> G["Find or pin a new location"]
  G --> H["Google Places suggestions"]
  H --> I["Fetch Place Details"]
  I --> J["Selected result + optional pin refinement"]
  G --> K["Manual pin fallback"]
  J --> L["Name and save"]
  K --> L
  F --> M["Return temporary selection"]
  L --> M
  M --> N["Save memory atomically"]
```

Interaction and validation:

- Search begins after at least two trimmed characters and a short debounce.
- One autocomplete session token is reused through suggestion selection, then rotated.
- Place Details is requested only after the user selects a suggestion.
- Search errors keep the query and expose retry/manual pin options.
- `displayName` is required before returning a new location.
- Coordinates must be finite and within valid latitude/longitude ranges.
- Private `Memory.note` remains memory-owned; Location Picker has no separate note field in this milestone.
- Reusing a location never duplicates it.
- If a Google result matches an existing `googlePlaceId`, reuse the existing internal location instead of creating a duplicate.

Current Google Places status:

- The Flutter Location Picker UI, debounce/controller flow, repository boundary, request headers, and error state are implemented.
- In the current local Android setup, autocomplete still returns no suggestions because Google Cloud responds with HTTP `403 PERMISSION_DENIED`.
- The tested Android restriction identity is package `vn.hung.le.lovejournal` with SHA-1 `9A:27:5D:11:3E:A1:38:DC:CC:25:39:D8:D3:7E:00:A1:94:34:5F:A0`.
- This is treated as an environment/API-key blocker, not a reason to move search into Map or reintroduce hardcoded places.
- The UI must continue to offer manual pin fallback and a clear retry/error state while Places permission is unresolved.

### Lời Nhắn Cho Khoảnh Khắc Này

This is the current UX replacement for a generic `Audio` field.

Empty state:

- title: `Chưa có lời nhắn`;
- helper: `Ghi âm mới hoặc chọn một đoạn audio có sẵn trong máy.`;
- CTA: `Thêm lời nhắn`.

Source sheet:

- title: `Thêm lời nhắn`;
- actions:
  - `Chọn từ máy`;
  - `Ghi âm mới`.

Recorder sheet:

- title: `Lời nhắn cho khoảnh khắc này`;
- circular mic visual;
- timer mock: `00:34`;
- waveform/player mock;
- actions:
  - `Hủy ghi âm`;
  - `Lưu lời nhắn`.

List item:

- play icon;
- title or file name;
- source label:
  - `Ghi âm`;
  - `Từ máy`;
- duration;
- delete icon.

Limits:

- MVP allows up to 3 voice messages per memory.

Current implementation note:

- File picking and recording are mocked.
- Mock URI format: `mock://...`.
- Native implementation should be added later behind service abstractions.

### Tag Selector

Current behavior:

- uses wrap/flex layout;
- each chip sizes to its text;
- chips flow horizontally and wrap to next line;
- chips must not stretch to full row width;
- custom tag names should not overflow the parent;
- selected tag is highlighted using `AppFilterChip`.

Actions:

- select existing tag;
- tap `+ Tạo nhãn`;
- bottom sheet opens;
- enter custom tag name;
- save tag;
- new tag is selected.

Implementation note:

- The create-tag bottom sheet owns its text controller inside the sheet widget lifecycle.
- Dismissing the sheet must not throw `TextEditingController was used after being disposed`.

Important rule:

- `Tất cả` is not stored as a tag.
- `Tất cả` exists only on the Time filter.

### Media Groups

Purpose:

- organize photos/videos into story segments;
- each group can have its own note.

Current behavior:

- groups are dynamic;
- max 3 groups per memory for MVP;
- group counter is shown:
  - `0/3 nhóm`;
  - `1/3 nhóm`;
  - `2/3 nhóm`;
  - `3/3 nhóm`.

Empty state:

- title: `Chưa có nhóm media`;
- helper: `Tạo nhóm đầu tiên rồi thêm ảnh/video vào đoạn câu chuyện đó.`;
- CTA: `Thêm nhóm media`.

Group card:

- runtime label, for example `Nhóm media · 1/3`;
- helper: `Ảnh và video cùng một đoạn câu chuyện`;
- note text field;
- grid with mixed image/video items;
- add media tile;
- item count footer;
- action menu.

Group actions:

- add media;
- move group up;
- move group down;
- delete group.

Media source sheet:

- `Thêm ảnh từ thư viện`;
- `Thêm video từ thư viện`;
- `Chụp hoặc quay mới`.

Current implementation note:

- Image/video picking is mocked.
- Mock media uses `AppAssets.heroImage`.
- Video is represented by a thumbnail plus play icon.

Media group flow:

```mermaid
flowchart TD
  A["Media groups section"] --> B{"Có group?"}
  B -->|"Không"| C["Empty group state"]
  C --> D["Thêm nhóm media"]
  B -->|"Có"| E["Group list"]

  D --> F{"Số group < 3?"}
  F -->|"Có"| G["Create group"]
  F -->|"Không"| H["Disable add group"]

  E --> I["Edit group note"]
  E --> J["Add media"]
  J --> K["Media source sheet"]
  K --> L["Add image mock"]
  K --> M["Add video mock"]
  K --> N["Camera mock"]

  E --> O["Group menu"]
  O --> P["Move up/down"]
  O --> Q["Delete group"]
```

## Screen: Memory Detail

File:

- `lib/src/features/journal/presentation/screens/memory_detail_screen.dart`

Purpose:

- let one memory breathe;
- show the story, cover, quote, voice messages, and media groups.

Current UI:

1. Cover media
   - height around 324;
   - hero image transition tag;
   - photo overlay;
   - back and favorite circular buttons.

2. Detail sheet
   - date/place;
   - title;
   - story split into shorter blocks when long;
   - favorite quote if available;
   - `Lời nhắn cho khoảnh khắc này` if voice messages exist.

3. Additional content
   - message for her quote if available;
   - media groups if available;
   - old flat media carousel fallback if no groups.

Voice message display:

- section label;
- voice player rows with duration;
- playback remains visual/mock.

Media group display:

- group note appears before its carousel;
- carousel shows group items;
- falls back to flat `memory.media` when no groups exist.

## Screen: Map

File:

- `lib/src/features/journal/presentation/screens/map_screen.dart`

Purpose:

- turn memories into places and a journey.

### Previous Implementation (Removed)

The previous Flutter screen was a transitional implementation:

- top bar:
  - kicker: `Những nơi mình qua`;
  - title: `Bản đồ`;
  - recenter icon;
- real Google Map surface when a platform Maps key is configured;
- warm static fallback canvas when the API key is missing;
- saved place markers from `assets/data/places.json`;
- floating search field for Google Places Autocomplete;
- autocomplete result list with loading, empty, and error states;
- saved places rail above the bottom tab bar;
- selected search result card with address and future note/attach hint.

Interaction:

- tap saved marker opens `PlacePreviewSheet`;
- bottom sheet shows place preview;
- opening a place opens first memory for that place if available.
- tap saved place chip recenters the map and opens the same preview;
- type at least 2 characters to search Google Places;
- tap a suggestion to fetch Place Details, drop a temporary marker, and animate the camera to that result;
- clearing search removes the temporary result marker/card.

Implemented limitation:

- The current implementation uses `google_maps_flutter` and Google Places Web Service.
- API keys are supplied by environment/build configuration, never committed.
- Search result selection is exploratory for now; searched places and notes are not persisted yet.
- If the API key is absent, the app keeps a static fallback surface so local development and tests do not crash.
- Marker ownership still comes from `assets/data/places.json`, not from editable memory locations.
- This search field, saved-place rail, and bundled-place ownership are legacy relative to the approved target.

### Current Implementation

Map is a read-only projection of memories. It does not create, search, edit, or independently own places.

Target UI:

- top bar keeps `Những nơi mình qua`, `Bản đồ`, and recenter action;
- real Google Map when a platform key is configured;
- one marker per internal `locationId` referenced by at least one visible memory;
- marker visual may indicate the number of memories without changing marker identity;
- no Google Places search field;
- no add-place action;
- no saved-place management rail;
- warm marker preview/list bottom sheet with an opaque background;
- empty state when no visible memory has a valid location;
- clear missing-key fallback when map rendering is unavailable.

Target interaction:

- tap marker to open the location's memory list;
- show user-defined location name and optional formatted address;
- show each visible memory with cover, title, date, and short story preview;
- tap a memory to open Memory Detail through the Map branch;
- recenter frames all visible markers;
- memories without `locationId` or valid coordinates do not render;
- soft-deleted memories are excluded from marker existence and counts.

Projection updates:

- saving a memory with a location adds it to the marker group;
- editing `locationId` moves the memory to another group;
- removing location removes only that memory from Map;
- soft-deleting the final visible memory at a location removes its marker;
- the Map screen watches journal state and must not maintain a second independently mutable place list.

## Screen: Letters

File:

- `lib/src/features/journal/presentation/screens/letters_screen.dart`

Purpose:

- private time capsule.

Current UI:

- top bar:
  - kicker: `Dành cho em`;
  - title: `Những lá thư`;
  - mail icon;
- list of letter cards;
- bottom tab bar visible.

Letter states:

- `open`;
- `locked`;
- `opened`.

Interaction:

- tapping open/opened letter navigates to Letter Detail;
- tapping locked letter opens bottom sheet explaining unlock date/countdown.

Locked letter UX:

- body is not exposed;
- card shows locked/countdown state only;
- bottom sheet explains when it opens.

## Screen: Letter Detail

File:

- `lib/src/features/journal/presentation/screens/letter_detail_screen.dart`

Purpose:

- slow reading moment;
- emotional text-first surface.

Current UI:

- top action row:
  - back;
  - heart/favorite visual action;
- envelope/paper visual style;
- occasion;
- title;
- letter body;
- primary CTA style button.

UX notes:

- Reads like a private note, not a content article.
- Keep paragraphs breathable.

## Screen: Recap

File:

- `lib/src/features/journal/presentation/screens/recap_screen.dart`

Purpose:

- emotional peak / anniversary summary.

Current UI:

- back button;
- hero memory card;
- stats grid:
  - days;
  - places;
  - photos;
  - letters;
- final quote block;
- CTA: `Cùng anh viết tiếp nhé?`.

Empty-safe behavior:

- if there is no featured memory, fallback hero image is used.
- photo count uses visible memories only.

## Components Currently Used

Core presentation components:

- `AppScaffold`
- `TopBar`
- `EmptyStateCard`
- `SectionHeader`
- `AppCircleButton`
- `PrimaryButton`
- `SecondaryButton`
- `AppFilterChip`
- `AppBottomTabBar`
- `HeroMemoryCard`
- `MemoryListCard`
- `TimelineSpine`
- `MemoryThumbnail`
- `AssetCoverImage`
- `MediaCarousel`
- `QuoteBlock`
- `VoiceNotePlayer`
- `StatCard`
- `LetterCard`
- `PlacePreviewSheet`

Component behavior notes:

- `AppScaffold` provides warm page gradient.
- `AppBottomTabBar` is a floating, blurred pill nav.
- `AppFilterChip` is used both for Time filters and form tag chips.
- `MemoryListCard` now supports optional tag label, media summary, and more action.
- `TimelineSpine` supports optional metadata and overflow actions.
- `VoiceNotePlayer` is visual-only for now.
- `LocationMemoryListSheet` is the current Map marker bottom sheet.
- `PlacePreviewSheet` is legacy and should not be used for the read-only memory-derived Map flow.

## Bottom Sheets

Bottom sheets are a core UX surface in the current app.

Used for:

- locked letter explanation;
- place preview;
- memory action menu;
- create custom tag;
- voice message source;
- recorder mock;
- media source.

Current visual style:

- background: `AppColors.paper`;
- rounded top corners;
- no transparent background;
- optional handle;
- warm copy;
- action rows/cards.

## Current Data/UX Constraints

Local-first:

- app works offline with bundled assets and local draft data.

Current persistence:

- app session uses SharedPreferences;
- editable memories/tags use SharedPreferences draft JSON.

Current mock limitations:

- media picker is mocked;
- audio picker is mocked;
- recorder is mocked;
- video playback is mocked;
- voice playback is mocked;
- Time search is not implemented;
- Google Places search UI is implemented in Location Picker but currently blocked by Google Cloud `403 PERMISSION_DENIED` in the local Android setup;
- no undo/trash UI for soft delete;
- no account/cloud sync.

## UX Rules To Preserve

1. Time is not just a list of photos.
2. Add/Edit Memory must remain story-first.
3. `Lời nhắn cho khoảnh khắc này` replaces a generic `Audio` field.
4. Media groups are dynamic and limited to 3 for MVP.
5. `Tất cả` is a UI filter, not stored as a tag.
6. Custom tags must appear as Time filter chips.
7. Tag chips should shrink-wrap to their text and wrap like flexbox items.
8. Bottom sheets must have visible warm background.
9. Empty states should be emotional and actionable.
10. Soft delete should hide memories without destroying data.
11. Keep user-facing copy in localization resources.
12. Keep the app local-first until auth/sync is intentionally designed.
13. Keep Google Maps API keys outside Git and preserve the no-key fallback for local development.
14. Create or choose locations only from Add/Edit Memory.
15. Keep Map read-only and derive it from visible memories.
16. Use a user-controlled location display name even when coordinates came from Google.
17. Keep private notes attached to memories, not locations.

## UI/UX Verification Checklist

Use this checklist after major UI changes:

- Opening appears only before `hasSeenOpening`.
- Home does not crash when there are no memories.
- Home uses visible memory count.
- Time title is `Time`, kicker is `Theo dòng thời gian`.
- Time has `Tất cả` plus dynamic tag chips.
- Time empty state has CTA.
- Time filtered empty state has CTA.
- Memory card overflow opens action sheet with background.
- Delete action asks for confirmation.
- Add Memory hides bottom tab bar.
- Edit Memory hides bottom tab bar.
- Location Picker hides bottom tab bar.
- Canceling Location Picker does not create or persist a location.
- The form can reuse an existing location without duplicating it.
- Google Places search appears only in Location Picker.
- Selecting a suggestion fetches Place Details and allows pin refinement.
- Manual pinning works without a `googlePlaceId`.
- A new location requires a user-confirmed display name.
- Tag selector wraps chips to next line.
- Tag selector chips size to text, not equal full-width rows.
- Create-tag bottom sheet can be dismissed without controller lifecycle exceptions.
- Custom tag appears in form and Time filter.
- Voice message section is named `Lời nhắn cho khoảnh khắc này`.
- No separate generic `Audio` field appears.
- Media groups show `0/3`, `1/3`, `2/3`, `3/3` style limit.
- Add group is disabled/hidden at 3 groups.
- Memory Detail shows voice messages and media groups.
- Locked letters do not expose body content.
- Map bottom sheet has visible background.
- Map shows a real Google Map when a platform Maps key is configured.
- Map shows a clear API-key fallback state when the key is absent.
- Map has no search/add/edit place controls after the approved refactor.
- Map empty state appears when no visible memory has a valid location.
- Memories sharing a `locationId` appear under one marker and one memory list.
- Changing/removing a memory location updates Map projection.
- Soft-deleting the final memory at a location removes its marker.
- Recap works even with no featured memory.

## Next UI/UX Work

Recommended next design/implementation passes:

1. Add more widget tests for Time empty, add memory, custom tag, soft delete, Location Picker, and Map projection.
2. Design real permission states for microphone, photos, and camera.
3. Replace mock audio/media with native services.
4. Add Time search UX and undo/trash recovery.
5. Add accessibility pass:
   - semantic labels;
   - text scale;
   - contrast checks;
   - touch targets.
6. Add responsive checks for smaller Android devices.

