# Flutter Client Context Index

Last updated: 2026-08-08

Thư mục này là bộ nhớ phát triển chi tiết của riêng Flutter client. `docs/current-context.md` chỉ giữ snapshot ngắn và trỏ tới các file ở đây.

## Cách đọc trong thread mới

1. Đọc `docs/current-context.md` để biết trạng thái tổng thể.
2. Đọc `project-foundation.md` trước khi thay đổi kiến trúc, provider hoặc navigation.
3. Chỉ đọc file module liên quan tới công việc đang làm.
4. Đọc `platform-quality.md` trước khi chạy build, thay dependency/native config hoặc kết thúc một thay đổi lớn.
5. Với contract dùng chung mobile/backend, đọc `.context/love-journal-context/` thay vì sao chép nội dung sang đây.

## Module Index

| File | Phạm vi | Trạng thái chính |
| --- | --- | --- |
| `project-foundation.md` | Intent, kiến trúc Flutter, Riverpod, GoRouter, design rules | Đã triển khai |
| `auth.md` | Login, Google, Email OTP, session, sign-out | Flutter client implemented; external config/backend pending |
| `home.md` | Home "Nhật ký sống" | Stage 1 đã triển khai |
| `memories.md` | Time, Add/Edit, Memory Detail, media, tags, local draft | Đã triển khai local-first |
| `map-location.md` | Location Picker, Places, Map projection, key strategy | Đã triển khai local-first |
| `letters-recap.md` | Letters, Letter Detail, Recap | MVP đã triển khai |
| `platform-quality.md` | Persistence, native boundaries, verification, environment, commands, next steps | Đang duy trì |

## Source Of Truth

- UI/UX đang chạy: `docs/designs/love-journal-current-ui-ux.md`.
- Product/implementation spec: `docs/designs/love-journal-implementation-spec.md`.
- Visual tokens: `docs/designs/love-journal-design-tokens.json`.
- Shared contracts và backend plan: `.context/love-journal-context/`.
- Auth design đã duyệt và triển khai: `docs/designs/love-journal-auth-handoff.html`.

## Quy tắc cập nhật

- Thay đổi chỉ thuộc một module: cập nhật file module đó.
- Thay đổi ảnh hưởng nhiều module hoặc app shell: cập nhật `project-foundation.md`.
- Thay đổi build, native dependency, local persistence hoặc verification: cập nhật `platform-quality.md`.
- Chỉ cập nhật `docs/current-context.md` khi trạng thái tổng thể, module status hoặc quyết định khóa thay đổi.
- Không lặp lại API/domain contract đã có trong shared context repository.
