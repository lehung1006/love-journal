# Map And Location Module Context

Last updated: 2026-08-04

## Status

Memory-owned Location Picker và read-only Map projection đã triển khai local-first. `places.json` không còn là marker source.

Design source:

- [Figma - Love Journal Map + Memory Location](https://www.figma.com/design/b3zJU0jnS7ZFAaJNX6G5lC)

## Ownership Model

```txt
Add/Edit Memory
  -> Location Picker returns temporary selection
  -> Save Memory atomically commits new/reused MemoryLocation
  -> Map projects visible memories by locationId
```

- Location optional.
- New location chỉ được lưu cùng memory save để tránh orphan location.
- `Memory.locationId` là identity/grouping key nội bộ.
- `googlePlaceId` là external metadata optional và hỗ trợ dedupe Google result.
- User quyết định `displayName`; Google name chỉ là suggestion.
- Private note thuộc memory, không thuộc location.

## Location Picker

- Reuse existing memory location.
- Google Places Autocomplete chỉ nằm trong picker.
- Browse/select segmented control: `Xem` và `Chọn vị trí`.
- Pan/zoom không đổi coordinate và không gọi Places.
- Map tap hoặc marker drag-end tạo manual coordinate và chạy Nearby Search bán kính 150m, tối đa 8, rank distance.
- Nearby candidates hiện bằng marker và mirrored list.
- Chọn Autocomplete/Nearby candidate mới gọi compact Place Details.
- Preview có thể hiển thị transient photo, type, address, business status, attribution và Google Maps link.
- Nearby empty/error vẫn cho lưu manual coordinate.
- Search focus ẩn bottom context panel ngay; search/map Stack không resize vì keyboard.
- Dismiss keyboard khôi phục panel và giữ selection/draft.
- Choose/Name steps vẫn resize/scroll bình thường.

## Map Tab

- Read-only, không search/add/edit place.
- Marker chỉ từ visible memories có valid location.
- Nhiều memories cùng `locationId` được group một marker.
- Tap marker mở warm root-navigator bottom sheet liệt kê memories.
- Tap memory mở Memory Detail.
- No located memory: emotional empty state đi tới Add Memory.
- Missing Maps key: clear fallback, không crash.

Synchronization local:

- Create/edit/remove location phản ánh ngay trên Map projection.
- Soft-delete memory cuối tại location làm marker biến mất.
- Cancel picker hoặc abandon composer không tạo location.

## Data Model

`MemoryLocation` immutable:

- stable internal `id`;
- user-controlled `displayName`;
- optional `formattedAddress`;
- latitude/longitude;
- optional `googlePlaceId`;
- source `googlePlaces` hoặc `manual`;
- created/updated timestamps.

Legacy flat fields `locationName`, `latitude`, `longitude`, `placeId` vẫn readable. Legacy `placeId` không được tự hiểu là Google Place ID.

`JournalData.places`, `Place`, DTO cũ và `assets/data/places.json` chỉ còn compatibility boundary; asset hiện là `[]`.

## API Key And Places Strategy

- Android/iOS package: `vn.hung.le.lovejournal`.
- Android native Maps key từ Gradle property, environment hoặc ignored `android/local.properties`.
- iOS key từ ignored `ios/Flutter/Secrets.xcconfig` vào `Info.plist`.
- Direct Places REST là giải pháp local-first tạm thời.
- Places REST không hỗ trợ Android/iOS application restriction như native Maps SDK.
- Production phải đưa Places request qua backend/proxy và dùng Android-restricted key riêng cho map rendering.
- Không commit real key.

## Diagnostics History Worth Keeping

- Android-restricted REST key từng trả `403 PERMISSION_DENIED`; native bridge từng trả `9011 REQUEST_DENIED`.
- Billing/services/project ownership đã được kiểm tra; cùng key từng thành công ở Cloud Shell nhưng thất bại từ Windows/device.
- Replacement key với billing setup khác trả HTTP 200 từ Windows và chứng minh Flutter REST payload đúng.
- Không dùng billing country sai sự thật như production workaround. Distribution tại Việt Nam cần strategy tuân thủ provider/territory rules.
- REST intentionally omits `X-Android-Package`, `X-Android-Cert` và iOS bundle headers.

## Tests And Rules

- Toolbar phải fit 320/360/430 và 200% text scale.
- Search focus hide/restore panel không mất selection.
- Root marker sheet phải nằm trên shell tab bar.
- Location Picker cancel không persist.
- Không đưa search/hardcoded places trở lại Map.
- Map count dùng `mapLocationGroups`, không dùng legacy places.
