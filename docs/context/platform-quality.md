# Platform And Quality Context

Last updated: 2026-08-08

## Local Persistence

SharedPreferences hiện lưu:

- `hasSeenOpening`;
- `openedLetterIds`;
- `favoriteMemoryIds`;
- `lastViewedMemoryId`;
- `journalDataDraft.v2`;
- independent Memory Composer drafts.

MVP local-first đang hoạt động, nhưng trước sync cần chuyển editable data sang local database có migration, transaction và query tốt hơn.

## Native Boundaries

Đã thật trên thiết bị:

- image selection và camera qua `image_picker`;
- multi-video/audio file selection qua `file_picker`;
- voice recording qua `record`;
- copy attachment vào app-owned storage;
- first-frame thumbnail qua `video_thumbnail_gen`;
- viewer/playback qua `video_player`;
- Google Maps native rendering và Places REST local-first.

Chưa hoàn thiện:

- real audio playback;
- permission denied/settings UX;
- orphan attachment cleanup;
- cloud object storage/upload/transcoding;
- sync/conflict resolution;
- backend Places proxy;
- partner/couple ownership và local-data migration theo UID;
- Firebase project credentials và backend Email OTP runtime.

## Verification Snapshot

Baseline trước khi triển khai Auth:

- Home stage 1 widget coverage: 320/393/430, large text, empty/one/many, navigation, static video, Reduce Motion.
- Composer/media tests: draft codec, 3-video limit, progress overlay, per-video thumbnail, viewer và cover replay policy.
- Location tests: toolbar responsive, focus/keyboard restore, root marker sheet above tab shell.
- `flutter analyze`: passed.
- `flutter test --no-pub`: passed trước lượt design auth hiện tại.
- `flutter build apk --debug --no-pub`: passed ở các mốc Home/Composer/Map gần nhất.
- `flutter build web --no-pub`: từng pass gồm Wasm dry run.

Auth client verification ngày 2026-08-08:

- `flutter analyze --no-pub`: passed.
- toàn bộ `flutter test --no-pub`: passed, gồm Sign In responsive 320/393/430, large text, missing-config, debug Email OTP, Opening, Home account sheet và sign-out.
- Android debug APK build: passed after stopping stale Gradle daemons and clearing the locked workspace `build/` output.

## Windows Environment

Project:

```txt
D:\Flutter\projects\flutter_love_journal
```

Flutter SDK:

```txt
D:\Flutter\flutter
```

Recommended user env:

```powershell
[Environment]::SetEnvironmentVariable('PUB_CACHE','D:\Flutter\pub-cache','User')
[Environment]::SetEnvironmentVariable('GRADLE_USER_HOME','D:\Flutter\gradle-cache','User')
```

Codex may use workspace-local temp env to avoid blocked AppData writes. Remove `.codex_tool_env` before finishing.

Flutter plugin symlink creation on Windows may require Developer Mode.

## Commands

```powershell
git submodule update --init --recursive
flutter pub get
flutter analyze
flutter test
flutter build apk --debug
flutter build web
```

## Maps Secrets

Android local key belongs in ignored `android/local.properties`:

```txt
GOOGLE_MAPS_ANDROID_API_KEY=your_local_key
```

iOS local key belongs in ignored `ios/Flutter/Secrets.xcconfig`:

```txt
GOOGLE_MAPS_IOS_API_KEY=your_ios_key
```

Do not commit real keys. Direct Places REST key strategy is temporary; see `map-location.md`.

## Auth Runtime Config

Auth dùng ignored `config/auth.dev.json`, tạo từ `config/auth.dev.example.json`, rồi chạy:

```powershell
flutter run --dart-define-from-file=config/auth.dev.json
```

Không commit Firebase API key, OAuth client ID hoặc backend URL dành riêng cho môi trường. Chi tiết biến và các bước thiết lập nằm ở `auth.md`.

## Current Recommended Order

1. Configure Firebase Android/Google sign-in and verify a real Google session.
2. Implement backend Email OTP and publish the first OpenAPI contract through the context repository.
3. Reconcile the provisional OTP adapter with that released contract.
4. Design local-data migration and partner onboarding as separate modules.
5. Move journal persistence from SharedPreferences JSON to a real local database.
6. Add audio playback, permission recovery and orphan-file cleanup.
7. Move Places Web Service behind backend/proxy before production.

## Final Checks For Code Changes

- Read `git status` first and preserve unrelated/user changes.
- Run l10n generation after ARB changes.
- Run formatter only on touched Dart files.
- Run `flutter analyze` and relevant tests; broaden to full suite for shared behavior.
- Build Android when native/plugin/config changes.
- Verify responsive UI at 320/393/430 and large text when presentation changes.
- Update only the affected module context, plus `docs/current-context.md` when global status changes.
