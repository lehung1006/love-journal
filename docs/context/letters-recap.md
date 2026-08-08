# Letters And Recap Module Context

Last updated: 2026-08-04

## Status

Letters, Letter Detail và Three-Year Recap đã triển khai ở mức local MVP. Chưa có create/edit letter, cloud ownership hoặc notification delivery.

## Letters

- Root tab route: `/letters`.
- Detail route: `/letters/:letterId`, không hiện bottom tab bar.
- Letter list đọc bundled/local journal data.
- Locked letter chỉ hiển thị cover metadata và unlock state, không lộ body.
- Opened letter IDs được lưu trong session preferences.
- Home dùng pinned/next letter qua compact strip và mở cùng Letter Detail flow.

## Letter Detail

- Ưu tiên typography và emotional pacing.
- Chỉ được mở body khi lock rule cho phép.
- `markLetterOpened` chạy qua `journalSessionControllerProvider`.
- Không đưa edit controls vào read-only detail cho tới khi letter-management được thiết kế riêng.

## Recap

- Routes: `/home/recap`.
- Mở từ Home hero, heart action và Recap band.
- Hoạt động cả khi không có featured memory.
- Current recap dựa trên local journal data và anniversary dates.
- Chưa có AI generation, export pipeline, watch-together playback hoặc shared session.

## Future Boundaries

- Letter authoring/scheduling là module riêng.
- Push notification chỉ signal người dùng, không chứa private letter body.
- Shared/couple authorization phải được backend kiểm tra trước khi tải letter.
- AI recap/export cần consent, privacy và media ownership rõ trước khi triển khai.

## Rules To Preserve

- Locked letter không được leak content qua preview, semantics, notification hoặc logs.
- Letter/Recap giữ visual hierarchy cảm xúc, không biến thành dashboard cards.
- User-facing copy phải qua l10n.
- Detail routes không hiện persistent bottom tab bar.
