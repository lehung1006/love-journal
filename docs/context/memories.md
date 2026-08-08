# Memories Module Context

Last updated: 2026-08-04

## Scope And Status

Module gồm Time, Add/Edit Memory Composer, Memory Detail, tags, voice message, media groups và local draft recovery. Phần local-first đã triển khai; cloud sync chưa có.

References:

- `docs/designs/love-journal-memory-composer-handoff.html`
- `docs/designs/love-journal-time-management-handoff.html`
- `lib/src/features/journal/presentation/screens/timeline_screen.dart`
- `lib/src/features/journal/presentation/screens/memory_form_screen.dart`
- `lib/src/features/journal/presentation/screens/memory_detail_screen.dart`

## Time

- Chỉ hiển thị visible memories.
- Filter luôn có `Tất cả` và dynamic tag chips shrink-wrap/wrap theo hàng.
- Memory card có cover, title, date/place, story ngắn, tag, media summary và action menu.
- Có empty state tổng và empty state theo filter.
- Hỗ trợ Add, Edit, soft-delete và Set featured.
- Search và trash/undo chưa triển khai.

## Memory Composer

- Là visual composer, không phải long-form note.
- Empty canvas có ba entry point: image/video, viết một dòng, voice message.
- Date, primary tag và optional location nằm trong compact metadata chips.
- Date dùng fixed 42-cell month sheet; đổi tháng bằng state update trực tiếp để tránh lag animation mặc định.
- Title tự sinh từ story/location/tag-date và vẫn sửa được ở header.
- Legacy description/private note được merge vào story khi edit.
- Save thành công mở Memory Detail.

Validation:

- Title có thể tự sinh.
- Cần ít nhất một body element: story, voice, image hoặc video.
- Date và `Đời thường` được preselect.
- Location riêng lẻ không phải meaningful content.

## Voice Message

- Tên UI: `Lời nhắn cho khoảnh khắc này`.
- Import audio file hoặc record microphone.
- Tối đa 3 voice messages.
- Playback thật chưa triển khai, control hiện còn visual.

## Media Groups

- Dynamic mixed image/video groups, tối đa 3 group.
- Mỗi group có editable title, optional note và sort order.
- Legacy group chưa có title fallback `Đoạn x`.
- Native photo/camera/video picker; file được copy vào app-owned storage.
- Tối đa 3 video trên toàn memory.
- Video import lớn/nhiều file có blocking warm progress và current `x/n`.
- Mỗi imported video tạo first-frame JPEG thumbnail và lưu `thumbnailUri` riêng.
- Tap media mở full-screen swipeable viewer từ Composer và Memory Detail.
- Image zoom; video chỉ play/pause, không seek.
- Cover video autoplay tối đa 3 completed runs; manual replay sau đó chạy một lần.

## Draft State

- `MemoryComposerDraft` immutable và serialize độc lập.
- `MemoryComposerController` là Riverpod family controller theo new/edit draft id.
- Debounce-save SharedPreferences; flush ngay khi close/back.
- Reopen meaningful draft cho Resume/Discard.
- Submit thành công hủy autosave và xóa composer draft.

## Important Models

- `MemoryTag`
  - Dynamic tag; system tags được tạo từ legacy category.
- `MemoryVoiceMessage`
  - Source `imported` hoặc `recorded`.
- `MemoryMediaGroup`
  - Editable title, optional note, mixed items, sort order.
- `MemoryMedia`
  - Image/video metadata và optional persisted `thumbnailUri`.
- `deletedAt`
  - Soft-delete marker.

`MemoryCategory` và một số legacy fields vẫn được đọc để tương thích seed/draft cũ.

## Persistence

- Editable journal key: `journalDataDraft.v2`.
- Stores memories, tags, soft-deleted state, voice metadata, media groups và locations/references.
- `assets/data/memories.json` là `[]`; memory mới do người dùng tạo.
- Draft v1 bị bỏ qua có chủ đích để hardcoded seed cũ không quay lại.

SharedPreferences draft JSON chỉ phù hợp MVP. Trước cloud sync cần local database có transaction/query/migration tốt hơn.

## Known Gaps

- audio playback;
- permission-denied/settings UX;
- orphan attachment cleanup;
- thumbnail/media cache lifecycle;
- Time search;
- trash/undo;
- UID/couple-space ownership và sync.

## Rules To Preserve

- Memory là emotional object; media chỉ hỗ trợ câu chuyện.
- Không thêm generic Audio field song song với voice-message section.
- Enforce giới hạn group/video ở cả UI và controller.
- Viewer không được mutate hoặc làm mất composer draft.
- User-facing copy nằm trong l10n.
- Location được chọn trong memory flow; chi tiết nằm ở `map-location.md`.
