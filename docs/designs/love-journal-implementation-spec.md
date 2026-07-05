# Mình & Em - Mobile App Implementation Spec

Version: 1.0  
Target: Flutter or React Native  
Design board: `love-journal-figma-handoff.html`  
Time management extension: `love-journal-time-management-handoff.html`  
Current UI/UX source of truth: `love-journal-current-ui-ux.md`  
Token file: `love-journal-design-tokens.json`

## Product Intent

Important: this file contains the product and implementation spec across MVP and product-extension phases. For the UI/UX that is currently implemented in the Flutter app, read `love-journal-current-ui-ux.md` first.

`Mình & Em` is a private memory journal for a couple. The first release is a local-first anniversary gift app. The product direction later is a shared couple journal with sync, private letters, timeline, maps, reminders, and recap generation.

Core principle: this is not a photo gallery. It is a curated emotional archive.

## MVP Scope

Build these screens first:

1. Opening Gift
2. Home
3. Timeline
4. Memory Detail
5. Letters
6. Letter Detail
7. Three-Year Recap
8. Map

Post-MVP:

1. Add/Edit Memory
2. Account and partner invite
3. Cloud sync
4. Privacy lock
5. AI recap/export

Current product milestone:

1. Upgrade Timeline/Time into a memory management tab.
2. Add empty state for couples that have not written any memories yet.
3. Add create, edit, soft-delete flows for memories.
4. Replace fixed memory categories with data-driven tags.
5. Support moment voice messages and grouped image/video sections per memory.
6. Route user-facing app copy through localization resources.

## Navigation

Recommended structure:

```txt
AppRoot
  OpeningGate
    OpeningGift
  MainTabs
    HomeTab
      HomeScreen
      MemoryDetailScreen
      RecapScreen
    TimelineTab
      TimelineScreen
      MemoryDetailScreen
      AddMemoryScreen
      EditMemoryScreen
    MapTab
      MapScreen
      PlaceDetailSheet
      MemoryDetailScreen
    LettersTab
      LettersScreen
      LetterDetailScreen
  AddMemoryScreen
  EditMemoryScreen
```

Opening logic:

- Show `OpeningGift` on first launch.
- Persist `hasSeenOpening = true` locally after CTA tap.
- Allow replay later from Settings or hidden debug menu.

## Design Tokens

Use `love-journal-design-tokens.json` as the source of truth.

Important values:

```txt
Base frame: 393 x 852
Safe top: 59
Safe bottom: 34
Screen horizontal padding: 20
Card radius: 8
Primary button height: 52
Secondary button height: 44
Icon button size: 40
Tab bar height: 64
```

Typography:

```txt
Display: Georgia or platform serif
Body: Inter or platform sans
Display XL: 44 / 44
Display L: 34 / 36
Title L: 26 / 29
Body M: 14 / 21
Body S: 12 / 16
```

## Localization

For the Flutter implementation, user-facing app copy should live in gen-l10n ARB resources instead of being hardcoded in widgets.

Current setup:

- `flutter_localizations` and `intl`.
- `l10n.yaml`.
- `lib/l10n/app_vi.arb` as the Vietnamese template locale.
- Generated `AppLocalizations` imported by the app.
- `context.l10n` extension for presentation widgets.

Rules:

- Keep route names, storage keys, JSON field names, asset paths, mock URIs, and other data contracts outside localization.
- Keep system tag labels localized in presentation from stable `MemoryTag.systemIdForCategory(...)` IDs.
- Custom tag names are user data and should be displayed as entered.

## Data Models

### Memory

```ts
type MemoryCategory =
  | "trip"
  | "birthday"
  | "daily"
  | "milestone"
  | "anniversary";

type RelationshipPhase =
  | "year_1"
  | "year_2"
  | "year_3";

type Memory = {
  id: string;
  title: string;
  date: string; // ISO date
  category: MemoryCategory;
  phase: RelationshipPhase;
  locationName?: string;
  latitude?: number;
  longitude?: number;
  placeId?: string;
  media: MemoryMedia[];
  coverMediaId?: string;
  story: string;
  favoriteMoment?: string;
  messageForHer?: string;
  voiceNoteUrl?: string;
  isFeatured?: boolean;
  createdAt: string;
  updatedAt: string;
};

type MemoryMedia = {
  id: string;
  type: "image" | "video";
  uri: string;
  width?: number;
  height?: number;
  alt?: string;
};
```

### Memory Management Extension

For the editable product version, do not keep `MemoryCategory` as a fixed enum in the core domain model. Keep the seed JSON compatible during migration, but introduce data-driven tags for user-created labels.

```ts
type MemoryTag = {
  id: string;
  name: string;
  color?: "rose" | "teal" | "moss" | "amber" | "lavender";
  isSystem?: boolean;
  createdAt: string;
  updatedAt: string;
};

type EditableMemory = {
  id: string;
  title: string;
  description: string;
  occurredAt: string;
  locationName?: string;
  latitude?: number;
  longitude?: number;
  placeId?: string;
  note?: string;
  primaryTagId?: string;
  voiceMessages: MemoryVoiceMessage[];
  mediaGroups: MemoryMediaGroup[];
  coverMediaId?: string;
  isFeatured?: boolean;
  createdAt: string;
  updatedAt: string;
  deletedAt?: string;
};

type MemoryVoiceMessage = {
  id: string;
  uri: string;
  source: "imported" | "recorded";
  fileName?: string;
  title?: string;
  durationSeconds?: number;
  waveform?: number[];
  createdAt: string;
};

type MemoryMediaGroup = {
  id: string;
  note?: string;
  items: MemoryMedia[];
  sortOrder: number;
};
```

Rules:

- `Tất cả` is not stored as a tag. It is a default UI filter.
- System tags can seed `Chuyến đi`, `Sinh nhật`, `Đời thường`, `Dấu mốc`, `Kỷ niệm`.
- Custom tags are created by the user and appear as new chips in Time.
- Start with one primary tag per memory for a simpler MVP. Multi-tag can be added later without changing the screen layout.
- Use soft delete with `deletedAt` first. Hard delete can be a later storage cleanup action.

### Letter

```ts
type LetterStatus = "open" | "locked" | "opened";

type Letter = {
  id: string;
  title: string;
  occasion: string;
  preview?: string;
  body: string;
  unlockAt?: string; // ISO date
  status: LetterStatus;
  openedAt?: string;
  pinToHome?: boolean;
  coverStyle?: "rose" | "paper" | "night";
};
```

### Place

```ts
type Place = {
  id: string;
  name: string;
  latitude: number;
  longitude: number;
  memoryIds: string[];
  coverMediaId?: string;
  shortNote?: string;
};
```

### Place Search

The current Flutter implementation uses Google Places as an external search source, separate from persisted journal `Place` data.

```ts
type PlaceSearchSuggestion = {
  placeId: string;
  primaryText: string;
  secondaryText?: string;
  fullText: string;
};

type PlaceSearchResult = {
  placeId: string;
  name: string;
  formattedAddress?: string;
  latitude: number;
  longitude: number;
};
```

Rules:

- Search suggestions are exploratory until the user explicitly attaches/saves a place in a later flow.
- Do not commit Google Maps API keys.
- For production, consider routing Places Web Service calls through a backend/proxy if mobile key restrictions are not enough.
- The app must keep a no-key fallback state so local development and automated tests can run without secrets.

## Components

Create these before composing screens:

```txt
AppScaffold
StatusBarSpacer
TopBar
IconButton
PrimaryButton
SecondaryButton
BottomTabBar
FilterChip
HeroMemoryCard
StatCard
MemoryListCard
TimelineSpine
LetterCard
LockedLetterBadge
PlacePreviewSheet
VoiceNotePlayer
MediaCarousel
QuoteBlock
MemoryEmptyState
MemoryActionMenu
MemoryFormField
MemoryTagSelector
MomentMessageField
VoiceMessageSourceSheet
VoiceRecorderSheet
VoiceMessageListItem
MediaGroupEditor
MediaAddSourceSheet
MediaItemMenu
PhotoUploadField
TextField
```

## Screen Specs

### OpeningGift

Purpose: make the first app launch feel like opening a private gift.

Content:

- Full-screen vertical image/video background.
- Gradient overlay from transparent top to strong dark bottom.
- Kicker: `Gửi riêng em`.
- Title: `Ba năm, mình vẫn ở đây.`
- Body copy: short personal message.
- CTA: `Mở món quà`.

Behavior:

- On mount: background slow zoom 900ms.
- Text fade/stagger 120ms.
- CTA appears after text.
- On tap: persist `hasSeenOpening`, navigate to MainTabs/Home.

### Home

Purpose: emotional dashboard, not a utility dashboard.

Sections:

- Header: greeting + app title.
- Hero memory: love day counter.
- Stats: memory count, place count.
- Featured memory card.
- Next locked/open letter.
- Bottom tabs.

Rules:

- Hero media must be visually dominant.
- Keep copy short.
- Home should always have a primary next action.

### Timeline

Purpose: browse memories chronologically.

Sections:

- Header.
- Category chips.
- Phase/year label.
- Timeline spine list.

Behavior:

- Filter chips update list in place.
- Memory tap pushes `MemoryDetailScreen`.
- Scroll reveal: opacity 0 to 1, translateY 8px to 0.

Current product extension:

- Rename visible tab title to `Time` while keeping the kicker `Theo dòng thời gian`.
- Add search and add actions in the header.
- `Tất cả` is always the first chip.
- All other chips come from `MemoryTag` data, including user-created custom tags.
- Empty state when there are no memories at all:
  - Title: `Chưa có kỷ niệm nào được viết`
  - Body: `Bắt đầu bằng một khoảnh khắc nhỏ. Một buổi tối bình thường cũng xứng đáng được giữ lại.`
  - CTA: `Thêm kỷ niệm đầu tiên`
- Empty filtered state when the selected tag has no memory:
  - Title: `Chưa có kỷ niệm trong nhãn này`
  - Body: `Bạn có thể thêm một kỷ niệm mới vào nhãn đang chọn.`
  - CTA: `Thêm vào nhãn này`
- Memory card should show cover thumbnail, title, date/place, short description, primary tag, media summary, and overflow action menu.
- Overflow action menu should include edit, feature/unfeature, and soft delete.

### Add/Edit Memory

Purpose: create or update one curated memory without making the app feel like a generic gallery manager.

Route:

- `AddMemoryScreen`: pushed from Time header and empty state CTA.
- `EditMemoryScreen(memoryId)`: pushed from memory overflow menu.
- These routes should not show the bottom tab bar.

Sections:

- App bar with back action, title, and save action.
- Main detail sheet, visually related to `MemoryDetail`:
  - Title.
  - Description.
  - Time.
  - Location.
  - Private note.
  - `Lời nhắn cho khoảnh khắc này` area with empty state, imported audio, and recorded voice states.
- Tag selector:
  - Existing system/custom tags as chips.
  - Inline action to create a new tag.
  - MVP should allow one primary tag.
  - Chips should behave like flexbox row items: size to content, flow horizontally, and wrap to the next line.
  - Chips must not stretch into equal full-width rows.
  - The create-tag bottom sheet should own its text controller inside the sheet lifecycle so dismissing it cannot use a disposed controller.
- Media groups:
  - User can add groups dynamically.
  - MVP maximum is 3 groups per memory.
  - Each group has an optional note at the top.
  - Each group can contain images and videos mixed together.
  - Each group preserves sort order.
- Sticky save bar:
  - Primary CTA: `Lưu kỷ niệm`.
  - Show loading state when saving or uploading.

Lời nhắn UX:

- Do not render a separate `Audio` field. The feature label is always `Lời nhắn cho khoảnh khắc này`.
- This section can attach audio from the device or record a new voice message.
- The field must not render a fake fixed player when there is no message.
- Empty state:
  - Title: `Chưa có lời nhắn`
  - Helper: `Ghi âm mới hoặc chọn một đoạn audio có sẵn trong máy.`
  - Actions: `Chọn từ máy`, `Ghi âm`
- `Chọn từ máy` opens a bottom sheet first, then a system file picker.
  - Supported formats for MVP: mp3, m4a, wav.
  - After import, show a message row with play action, title/file name, waveform placeholder, duration, and overflow menu.
- `Ghi âm` opens an in-app recorder screen or bottom sheet.
  - States: idle, recording, paused, preview, saving, error.
  - Recording UI should show timer, live waveform/progress, pause/resume, cancel, and save.
  - After recording, user can preview and optionally rename before saving into the memory.
- Multiple voice messages are allowed. MVP should limit to 3 messages per memory.
- Voice message item menu:
  - Rename.
  - Replace file.
  - Delete from this memory.
- Permission states:
  - If microphone permission is denied, show explanation and a settings CTA.
  - If file picker is unavailable, show a retry/error state.

Media group UX:

- Media groups are not a plain gallery grid. Each group is a story segment.
- Media groups are created by user action, not fixed in the UI.
- Empty state:
  - Title: `Chưa có nhóm media`
  - Helper: `Tạo nhóm đầu tiên rồi thêm ảnh/video vào đoạn câu chuyện đó.`
  - CTA: `Thêm nhóm media`
- Show a group counter such as `0/3 nhóm`, `1/3 nhóm`, `3/3 nhóm`.
- When the memory reaches 3 groups, disable or hide the add-group CTA.
- Every group card should include:
  - Drag handle or reorder affordance.
  - Runtime group label, for example `Nhóm media · 1/3`.
  - Optional note field at the top.
  - Mixed image/video grid.
  - Add media tile.
  - Group actions menu.
  - Small footer with item count and reorder hint.
- Add media tile opens a source menu:
  - `Thêm ảnh từ thư viện`.
  - `Thêm video từ thư viện`.
  - `Chụp hoặc quay mới`.
- Each media item should have an overflow menu:
  - Move to cover.
  - Move to another group.
  - Delete from group.
- Group action menu:
  - Rename group label later if needed.
  - Duplicate group later if needed.
  - Delete group.
- Reorder rules:
  - Items can be reordered inside one group.
  - Groups can be reordered relative to each other.
  - `sortOrder` must be persisted for both groups and items.
- Empty group rules:
  - Empty groups can exist during editing.
  - Empty groups are not saved unless they contain a note.
  - If a group contains only a note, it can be saved as a story break.
  - User cannot create a fourth group in MVP.

Validation:

- Title is required.
- Date/time is required.
- At least one of description, note, voice message, image, or video should exist.
- Media group can be empty only while the user is editing; empty groups should not be saved.
- New custom tag names should be trimmed and de-duplicated case-insensitively.
- Imported voice message must have a readable local URI or uploaded remote URI before final save.
- Recorded voice message must be saved to local app storage before being attached to the memory.

Deletion:

- Use an action menu or confirmation sheet, not a bare destructive icon.
- First implementation should soft delete with `deletedAt`.
- Show a clear destructive label: `Xóa kỷ niệm`.
- Later product can add undo or trash recovery.

### MemoryDetail

Purpose: let one memory breathe.

Sections:

- Cover media.
- Back/favorite actions.
- Detail sheet: date, place, title, story.
- Quote block: favorite moment.
- Voice note optional.
- Gallery strip.

Rules:

- Avoid long dense paragraphs.
- Split long story into short blocks if over 600 characters.
- Voice note should show duration even if playback is not implemented yet.

### Map

Purpose: turn memories into a journey.

Current implementation:

- Real map surface uses `google_maps_flutter`.
- Place search uses Google Places Web Service through a repository/data-source boundary.
- Saved places from bundled JSON render as map markers.
- A warm static canvas remains as a fallback when `GOOGLE_MAPS_API_KEY` is not configured.

Behavior:

- Saved marker tap opens place preview bottom sheet.
- Place preview shows cover image, place name, memory count, short note.
- CTA opens filtered timeline or place detail.
- Search field calls Places Autocomplete after a short debounce.
- Selecting a suggestion fetches Place Details, moves the camera, and shows a temporary selected-place card.
- Selected search results are not persisted until a later attach/save flow is designed.

Configuration:

- Dart/Places calls read `GOOGLE_MAPS_API_KEY` from `--dart-define`.
- Android injects the same key through a manifest placeholder.
- iOS reads the same key from `Info.plist`/build settings.

### Letters

Purpose: private time capsule.

States:

- `open`: readable now.
- `locked`: countdown only, no body preview.
- `opened`: readable, marked as opened.

Behavior:

- Tap open letter pushes `LetterDetailScreen`.
- Tap locked letter opens bottom sheet explaining unlock date.

### LetterDetail

Purpose: slow reading moment.

Content:

- Back and favorite actions.
- Envelope visual.
- Occasion.
- Title.
- Letter body.
- Optional next/read more CTA.

Motion:

- Envelope unfold.
- Paper reveal.
- Body text fade in.

### Three-Year Recap

Purpose: final emotional peak.

Content:

- Recap hero image.
- Stats: days, cities/places, photos, letters.
- Final quote.
- CTA: `Cùng anh viết tiếp nhé?`

Behavior:

- Can be linked from Home.
- Can be shown after Opening for anniversary day.
- Later product: export/share recap.

## Motion

Use these defaults:

```txt
Fast: 160ms
Base: 260ms
Slow: 520ms
Ritual: 900ms
Curve standard: cubic-bezier(0.2, 0.8, 0.2, 1)
Curve soft: cubic-bezier(0.16, 1, 0.3, 1)
```

Motion rules:

- Do not animate every element.
- Use slow motion only for emotional moments: Opening, Letter, Recap.
- Respect reduced motion settings.
- Use shared element transition for memory cover if practical.

## Local-First MVP Storage

Recommended simple setup:

```txt
assets/
  data/
    memories.json
    letters.json
    places.json
  images/
  audio/
```

Persist only:

```txt
hasSeenOpening
openedLetterIds
favoriteMemoryIds
lastViewedMemoryId
```

Later product:

- Move data to SQLite/Isar/Realm.
- Add sync layer.
- Add auth and partner pairing.

## Seed Data Checklist

For the anniversary gift, prepare:

- 20-30 memories.
- 8-12 places.
- 3-5 letters.
- 1 final recap message.
- 1 voice note for the strongest memory.
- 1 vertical hero image/video for opening.
- 1 app icon.

Each memory should have:

```txt
title
date
locationName
category
1-5 photos
story
favoriteMoment
messageForHer optional
```

## Quality Checklist

Before giving the app:

- App opens offline.
- All local images load.
- No debug labels.
- Opening appears on first launch only.
- Letter lock dates are correct.
- Timeline sorted correctly.
- Love day counter is correct.
- Back navigation works everywhere.
- Text does not overflow on small devices.
- App icon and name are polished.
- No accidental private/dev content in release build.

## Implementation Recommendation

If deadline is close:

1. Build with local JSON and bundled assets.
2. Skip account/auth/sync.
3. Use static map if map SDK setup is risky.
4. Add only one polished animation: Opening to Home.
5. Make Memory Detail and Letters emotionally strong.

For product version:

1. Add Add/Edit Memory.
2. Add partner invite.
3. Add cloud media storage.
4. Add privacy lock.
5. Add recap/export.
