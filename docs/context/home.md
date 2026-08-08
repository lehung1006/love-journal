# Home Module Context

Last updated: 2026-08-08

## Status

Home "Nhật ký sống" stage 1 đã triển khai.

References:

- `docs/designs/love-journal-home-living-journal-handoff.html`
- `docs/designs/love-journal-home-living-journal-preview.png`
- `lib/src/features/journal/presentation/screens/home_screen.dart`
- `lib/src/features/journal/presentation/components/home_components.dart`

## Product Role

Home là trang cảm xúc được xem nhiều nhất, không phải dashboard tổng hợp. Nó giúp người dùng gặp lại ký ức, thư và recap mà không biến mỗi phần thành một card chức năng.

## Implemented Structure

1. Header
   - `Chào em` / `Mình & Em`.
   - Account avatar mở root-level account sheet.
   - Heart action mở Recap.
2. Living hero 334px
   - Featured memory, fallback là visible memory đầu tiên.
   - Hiển thị love-day count, title, date và location.
   - Image render trực tiếp; video chỉ dùng thumbnail tĩnh ở stage 1.
   - Tap mở Recap.
3. Stats ribbon
   - Love days.
   - `visibleMemories.length`.
   - `mapLocationGroups.length`, không dùng legacy places.
4. `Những mảnh ghép`
   - PageView tối đa 5 memory mới nhất, bỏ hero memory.
   - Hé lộ card tiếp theo; tap mở Memory Detail.
5. Compact letter section
   - Dùng pinned/next letter và giữ locked/opened label.
6. Recap band
   - Toàn bề mặt mở Recap.

## Empty State

- Dùng anniversary fallback image.
- Ẩn recent-memory PageView.
- CTA `Tạo kỷ niệm đầu tiên` đi tới Add Memory.
- Letter và Recap vẫn còn khả dụng.

## Motion

- Một entrance controller 760ms cho header, hero, stats và lower sections.
- Carousel scale nhẹ theo page distance.
- Khi `MediaQuery.disableAnimations` bật, content xuất hiện ngay và PageView không transform.
- Không có animation lặp ở stage 1.

## Deferred Stage 2

- daily-memory selector theo ngày;
- hero parallax;
- count-up stats;
- featured-memory priority trong carousel;
- muted video autoplay có tab/route lifecycle.

## Auth Integration

- `HomeScreen` nhận một optional `accountButton`; widget Home không đọc auth provider và không sở hữu auth logic.
- Router inject `AuthAccountButton` cạnh Recap khi session đã authenticated.
- Account sheet chỉ hiển thị avatar/initials, display name, email và sign-out.
- Sheet dùng root navigator để nằm trên shell tab bar; sign-out do `AuthController` xử lý và router redirect về Sign In.

## Tests To Preserve

- Width 320, 393, 430 và large text scale.
- Empty/one/many memory states.
- Hero/Recap interaction.
- Recent memory navigation.
- Empty Add Memory CTA.
- Static video thumbnail, không khởi tạo autoplay.
- Reduce Motion.
