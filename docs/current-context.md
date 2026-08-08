# Current Context - Flutter Love Journal

Last updated: 2026-08-08

## Purpose

Đây là entry point ngắn cho một Flutter client thread. Chi tiết đã được tách theo module trong `docs/context/` để thread mới không phải đọc một file rất dài.

Đọc theo thứ tự:

1. File này.
2. `docs/context/project-foundation.md` nếu thay đổi kiến trúc/app shell.
3. File module liên quan trong `docs/context/README.md`.
4. `.context/love-journal-context/` nếu công việc ảnh hưởng backend/shared contract.

## Product Snapshot

`Mình & Em` là love journal local-first, ban đầu dành cho một cặp đôi và hướng tới sản phẩm publish được với account, partner, sync, chat, notification, video call và watch-together.

Nguyên tắc cốt lõi:

> Đây không phải thư viện ảnh. Đây là một kho lưu trữ cảm xúc có chủ đích.

## Current Client Status

- Riverpod + immutable state models.
- Feature-first, repository/data-source separation.
- GoRouter `StatefulShellRoute.indexedStack` với Home, Time, Map, Letters.
- Flutter gen-l10n, Vietnamese template locale.
- SharedPreferences cho session và editable journal drafts.
- Native local image/video/audio picking, recording, thumbnails và media viewer.
- Empty bundled memory/place seeds; dữ liệu do người dùng tự tạo.
- Package/bundle id: `vn.hung.le.lovejournal`.
- Auth gate, Google/Firebase adapter, backend Email OTP adapter và account sign-out đã được triển khai ở Flutter.

## Module Status

| Module | Status | Context |
| --- | --- | --- |
| Project foundation | Implemented | `docs/context/project-foundation.md` |
| Auth | Client/UI implemented; Firebase config và backend OTP pending | `docs/context/auth.md` |
| Home | "Nhật ký sống" stage 1 implemented | `docs/context/home.md` |
| Memories | Time/Composer/Detail local-first implemented | `docs/context/memories.md` |
| Map & Location | Memory-owned picker + read-only projection implemented | `docs/context/map-location.md` |
| Letters & Recap | Local MVP implemented | `docs/context/letters-recap.md` |
| Platform & Quality | Ongoing | `docs/context/platform-quality.md` |

## Current Auth Decision

Thiết kế auth đã được duyệt và Flutter hiện có:

- Sign In, Email, OTP và account sheet theo handoff;
- Riverpod immutable auth/OTP state;
- GoRouter auth gate trước Opening và main shell;
- Firebase Authentication + Google adapter;
- adapter tạm thời cho hai endpoint Email OTP trong Managed-Balanced plan;
- debug-only bypass, chỉ hoạt động khi vừa là debug build vừa có `AUTH_DEV_BYPASS=true`.

Ứng dụng mặc định không giả đăng nhập khi thiếu dịch vụ ngoài. Để chạy auth thật cần cấu hình Firebase Android, Google provider/OAuth client và backend OTP. Xem toàn bộ biến môi trường, response shape tạm thời và checklist tại `docs/context/auth.md`.

## Shared Context

Private submodule:

- Repository: `lehung1006/love-journal-context`
- Local path: `.context/love-journal-context`
- Backend plan: `.context/love-journal-context/plans/managed-balanced-backend.md`

Initialize:

```bash
git submodule update --init --recursive
```

Shared repository là nguồn chuẩn cho domain/API/backend/integration decisions. Flutter repository là nguồn chuẩn cho client implementation và detailed UI/UX.

## Design Sources

- Current implemented UI/UX: `docs/designs/love-journal-current-ui-ux.md`.
- Product/implementation spec: `docs/designs/love-journal-implementation-spec.md`.
- Design tokens: `docs/designs/love-journal-design-tokens.json`.
- Auth handoff: `docs/designs/love-journal-auth-handoff.html`.
- Home handoff: `docs/designs/love-journal-home-living-journal-handoff.html`.
- Memory Composer: `docs/designs/love-journal-memory-composer-handoff.html`.
- Time management: `docs/designs/love-journal-time-management-handoff.html`.
- Map/Location Figma: [Love Journal Map + Memory Location](https://www.figma.com/design/b3zJU0jnS7ZFAaJNX6G5lC).

## Immediate Next Step

1. Tạo/cấu hình Firebase app Android cho `vn.hung.le.lovejournal`, bật Google provider và đăng ký SHA fingerprints.
2. Triển khai backend Foundation/Auth, chốt OpenAPI cho Email OTP rồi cập nhật adapter Flutter nếu contract khác response tạm thời.
3. Thiết kế module Onboarding & Partner và quyết định migration dữ liệu local theo UID/couple space.

## Thread Startup Checklist

- Đọc `AGENTS.md`.
- Khởi tạo submodule.
- Đọc file module liên quan, không đọc toàn bộ context nếu không cần.
- Kiểm tra `git status` trước khi sửa.
- Không ghi đè thay đổi chưa commit của người dùng.
- Không commit API key hoặc local secrets.
