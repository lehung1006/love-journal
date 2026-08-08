# Project Foundation Context

Last updated: 2026-08-08

## Product Intent

`flutter_love_journal` là Flutter client cho một nhật ký tình yêu riêng tư. Bản đầu là quà kỷ niệm local-first cho một cặp đôi; hướng dài hạn là sản phẩm publish được với tài khoản, partner/couple space, sync, chat, sticker, notification, video call và xem nhật ký cùng nhau.

Nguyên tắc sản phẩm:

> Đây không phải thư viện ảnh. Đây là một kho lưu trữ cảm xúc có chủ đích.

## Current Foundation

- Riverpod cho dependency graph và application/domain state.
- Immutable state models với `copyWith`.
- Feature-first dưới `lib/src/features/`.
- Tách domain, data source, repository, application và presentation.
- GoRouter với `StatefulShellRoute.indexedStack` cho bốn tab chính.
- Flutter gen-l10n, Vietnamese là template locale hiện tại.
- Local-first persistence qua SharedPreferences trong giai đoạn hiện tại.
- Android application id và iOS bundle id: `vn.hung.le.lovejournal`.

## App Flow

```txt
main.dart
  ProviderScope
    LoveJournalApp
      MaterialApp.router
        GoRouter
          AuthGate
            SignIn / Email / OTP
            OpeningGate
            MainNavigationShell
              Home / Time / Map / Letters
```

Gate hiện tại là:

```txt
AuthGate
  SignedOut -> Sign In / Email OTP
  SignedIn -> OpeningGate -> MainNavigationShell
```

Onboarding/Partner và quyết định migrate dữ liệu local chưa thuộc gate hiện tại; chúng sẽ được chèn sau auth khi module tương ứng được duyệt.

## Code Ownership

```txt
lib/src/app/
  app-level wiring, router, navigation shell

lib/src/core/
  api, config, localization, providers, storage, theme

lib/src/features/<feature>/
  domain/
  data/
  application/
  presentation/
```

Giữ API, JSON asset loading, persistence, repository, entities và widgets ở đúng layer. Widget state chỉ dành cho state cục bộ như focus, animation hoặc input tạm thời.

## Riverpod Providers

- `journalDataProvider`
  - `AsyncNotifierProvider<JournalDataController, JournalData>`.
  - Nạp seed từ repository, áp dụng local draft, xử lý create/update/soft-delete/feature memory và create tag.
- `journalSessionControllerProvider`
  - Quản lý `hasSeenOpening`, opened letters, favorite memories và last viewed memory.
- `journalRepositoryProvider`
  - Đọc seed journal qua `JournalAssetApiDataSource`.
- `mapServiceConfigProvider`
  - Đọc Maps key theo platform config.
- `placeSearchRepositoryProvider`
  - Places API (New) REST với boundary để sau này thay bằng backend proxy.
- `locationSearchControllerProvider`
  - Immutable Location Picker state, request generations và loading/error độc lập.
- `authControllerProvider`
  - Khôi phục Firebase session, Google sign-in, custom-token sign-in, sign-out và trạng thái router.
- `emailOtpControllerProvider`
  - Validation email, request/resend/verify OTP và chuyển custom token cho auth controller.
- `authRepositoryProvider` / `emailOtpRepositoryProvider`
  - Chọn adapter dịch vụ thật hoặc bypass debug có điều kiện; screens không gọi Firebase/HTTP trực tiếp.

## Navigation

Root/detail routes hiện tại:

```txt
/splash
/auth/sign-in
/auth/email
/auth/email/otp
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

Bottom tab chỉ xuất hiện tại `/home`, `/timeline`, `/map`, `/letters`. Form, picker và detail routes phải nằm ngoài bề mặt tab bar.

Mọi route không thuộc `/auth/*` đều yêu cầu authenticated session. Sau sign-in, router tiếp tục qua Opening; sau sign-out, router tự quay về Sign In.

## Visual Direction

- Warm paper background, white/warm surfaces, border/shadow nhẹ.
- Rose là primary accent; teal, moss, amber và lavender chỉ là màu hỗ trợ.
- Card radius 8px; pill chỉ dùng cho chip/action phù hợp.
- Serif cho display/emotional title, sans cho body và control.
- Không biến màn vận hành thành landing page hoặc một tập các card trang trí.
- User-facing copy phải đi qua gen-l10n.
- Bottom sheet phải có nền warm rõ và safe-area đúng.

## Shared Context Boundary

`.context/love-journal-context/` là nguồn chuẩn cho shared domain, backend architecture, API contract, ADR và integration status. Flutter docs chỉ ghi cách client hiện thực các contract đã phát hành.

Không sao chép shared Markdown vào Flutter repository. Khi shared contract thay đổi, review submodule commit rồi cập nhật pointer.

## Rules To Preserve

- Không bỏ repository/data-source abstraction dù hiện tại dùng JSON/local storage.
- Không quay về primary navigation bằng `setState` và danh sách widget thủ công.
- Không để provider presentation sở hữu business data của module khác.
- Không đưa Place search trở lại Map tab.
- Không commit API key, local secret, build output hoặc machine-specific files.
- Mọi thay đổi UI lớn phải đồng bộ source-of-truth trong `docs/designs/` sau khi được duyệt.
