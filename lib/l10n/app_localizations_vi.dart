// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get appTitle => 'Mình & Em';

  @override
  String get navHome => 'Home';

  @override
  String get navTime => 'Time';

  @override
  String get navMap => 'Map';

  @override
  String get navLetters => 'Thư';

  @override
  String get backTooltip => 'Quay lại';

  @override
  String get saveTooltip => 'Lưu';

  @override
  String get favoriteTooltip => 'Yêu thích';

  @override
  String get cancelAction => 'Hủy';

  @override
  String get deleteAction => 'Xóa';

  @override
  String get understoodAction => 'Đã hiểu';

  @override
  String get openingKicker => 'Gửi riêng em';

  @override
  String get openingTitle => 'Ba năm, mình vẫn ở đây.';

  @override
  String get openingBody =>
      'Anh gói lại vài nơi mình đã đi qua, vài ngày mình đã thương nhau, và một lời hẹn thật nhỏ cho chặng sau.';

  @override
  String get openingCta => 'Mở món quà';

  @override
  String get homeKicker => 'Chào em';

  @override
  String get homeRecapTooltip => 'Kỷ niệm 3 năm';

  @override
  String get homeHeroKicker => 'Kỷ niệm của tụi mình';

  @override
  String homeLoveDays(String days) {
    return '$days ngày yêu';
  }

  @override
  String get homeHeroSubtitle => 'Và anh vẫn muốn đi tiếp cùng em.';

  @override
  String get homeMemoriesWritten => 'kỷ niệm đã viết';

  @override
  String get homePlacesVisited => 'nơi mình đã qua';

  @override
  String get homeFeaturedMemory => 'Kỷ niệm nổi bật';

  @override
  String get homeNoFeaturedTitle => 'Chưa có kỷ niệm nổi bật';

  @override
  String get homeNoFeaturedBody =>
      'Khi thêm kỷ niệm đầu tiên, Home sẽ giữ lại khoảnh khắc đáng nhớ nhất ở đây.';

  @override
  String get homeNextLetter => 'Lá thư tiếp theo';

  @override
  String get homeNoLettersTitle => 'Chưa có lá thư nào';

  @override
  String get homeNoLettersBody =>
      'Khi có thư mới, Home sẽ luôn giữ một lời nhắn gần nhất.';

  @override
  String get homeRecapCta => 'Xem recap ba năm';

  @override
  String get timelineKicker => 'Theo dòng thời gian';

  @override
  String get timelineTitle => 'Time';

  @override
  String get timelineSearchTooltip => 'Tìm kỷ niệm';

  @override
  String get timelineAddMemoryTooltip => 'Thêm kỷ niệm';

  @override
  String get timelineAllYears => 'Tất cả năm';

  @override
  String get timelineAllFilter => 'Tất cả';

  @override
  String get timelineEmptyTitle => 'Chưa có kỷ niệm nào được viết';

  @override
  String get timelineEmptyBody =>
      'Bắt đầu bằng một khoảnh khắc nhỏ. Một buổi tối bình thường cũng xứng đáng được giữ lại.';

  @override
  String get timelineEmptyCta => 'Thêm kỷ niệm đầu tiên';

  @override
  String get timelineFilteredEmptyTitle => 'Chưa có kỷ niệm trong nhãn này';

  @override
  String get timelineFilteredEmptyBody =>
      'Bạn có thể thêm một kỷ niệm mới vào nhãn đang chọn.';

  @override
  String get timelineFilteredEmptyCta => 'Thêm vào nhãn này';

  @override
  String get timelineMemoryActionHelper => 'Chọn cách chỉnh sửa kỷ niệm này.';

  @override
  String get timelineEditMemory => 'Sửa kỷ niệm';

  @override
  String get timelineFeatureMemory => 'Đặt làm kỷ niệm nổi bật';

  @override
  String get timelineDeleteMemory => 'Xóa kỷ niệm';

  @override
  String get timelineDeleteTitle => 'Xóa kỷ niệm?';

  @override
  String timelineDeleteBody(String title) {
    return '“$title” sẽ được ẩn khỏi Time. Sau này có thể thêm thùng khôi phục khi có tài khoản/sync.';
  }

  @override
  String get memoryOptionsTooltip => 'Tùy chọn kỷ niệm';

  @override
  String get timelineFallbackEmptyBody =>
      'Khi có dữ liệu, timeline sẽ hiện theo thứ tự thời gian.';

  @override
  String mediaSummaryImages(int count) {
    return '$count ảnh';
  }

  @override
  String mediaSummaryVideos(int count) {
    return '$count video';
  }

  @override
  String mediaSummaryVoiceMessages(int count) {
    return '$count lời nhắn';
  }

  @override
  String get mediaSummaryEmpty => 'Chưa có media';

  @override
  String get categoryTrip => 'Chuyến đi';

  @override
  String get categoryBirthday => 'Sinh nhật';

  @override
  String get categoryDaily => 'Đời thường';

  @override
  String get categoryMilestone => 'Dấu mốc';

  @override
  String get categoryAnniversary => 'Kỷ niệm';

  @override
  String get phaseYear1 => 'Năm đầu tiên';

  @override
  String get phaseYear2 => 'Năm thứ hai';

  @override
  String get phaseYear3 => 'Năm thứ ba';

  @override
  String get mapKicker => 'Những nơi mình qua';

  @override
  String get mapTitle => 'Bản đồ';

  @override
  String get mapLocationTooltip => 'Địa điểm';

  @override
  String placeMemorySummary(int count, String note) {
    return '$count kỷ niệm · $note';
  }

  @override
  String get placeOpenMemories => 'Xem kỷ niệm';

  @override
  String get lettersKicker => 'Dành cho em';

  @override
  String get lettersTitle => 'Những lá thư';

  @override
  String get lettersTooltip => 'Thư';

  @override
  String get letterReservedDay => 'Một ngày được để dành';

  @override
  String letterOpensOn(String date) {
    return 'Mở vào $date';
  }

  @override
  String get letterLockedNoDateBody =>
      'Lá thư này đang được giữ lại cho đúng khoảnh khắc.';

  @override
  String letterLockedRemainingBody(int days) {
    return 'Còn $days ngày nữa lá thư này mới mở được.';
  }

  @override
  String get letterOpened => 'Đã mở';

  @override
  String get letterReady => 'Đã sẵn sàng';

  @override
  String letterDaysRemaining(int days) {
    return 'Còn $days ngày';
  }

  @override
  String get letterDetailToday => 'Mở vào hôm nay';

  @override
  String get letterKeepTooltip => 'Giữ lá thư';

  @override
  String get letterKeepCta => 'Giữ lá thư này';

  @override
  String get memoryDetailMomentMessage => 'Lời nhắn cho khoảnh khắc này';

  @override
  String get recapKicker => 'Kỷ niệm 3 năm';

  @override
  String get recapTitle => 'Mình đã đi qua thật nhiều.';

  @override
  String get recapSubtitle => 'Và anh vẫn muốn đi tiếp cùng em.';

  @override
  String get recapDaysLoved => 'ngày yêu';

  @override
  String get recapPlacesVisited => 'nơi đã qua';

  @override
  String get recapPhotos => 'tấm ảnh';

  @override
  String get recapLetters => 'lá thư';

  @override
  String get recapQuote =>
      'Ba năm không phải là điểm kết. Nó là bằng chứng rằng mình đã chọn nhau, rất nhiều lần.';

  @override
  String get recapCta => 'Cùng anh viết tiếp nhé?';

  @override
  String get routerUnknownError => 'Unknown error';

  @override
  String routerMissingParam(String name) {
    return 'Missing route parameter: $name';
  }

  @override
  String get routerErrorTitle => 'Chưa mở được nhật ký';

  @override
  String get memoryFormNewTitle => 'Kỷ niệm mới';

  @override
  String get memoryFormEditTitle => 'Sửa kỷ niệm';

  @override
  String get memoryFormSave => 'Lưu kỷ niệm';

  @override
  String get memoryFormSaving => 'Đang lưu...';

  @override
  String get memoryFormCreateTagTitle => 'Tạo nhãn mới';

  @override
  String get memoryFormCreateTagHint => 'Ví dụ: Cafe tối';

  @override
  String get memoryFormSaveTag => 'Lưu nhãn';

  @override
  String get memoryFormAddVoiceTitle => 'Thêm lời nhắn';

  @override
  String get memoryFormAddVoiceHelper =>
      'Chọn một file có sẵn hoặc ghi âm ngay trong app.';

  @override
  String get memoryFormPickFromDevice => 'Chọn từ máy';

  @override
  String get memoryFormPickAudioSubtitle =>
      'MVP sẽ thay mock này bằng file picker native.';

  @override
  String get memoryFormRecordNew => 'Ghi âm mới';

  @override
  String get memoryFormRecordSubtitle =>
      'Mở giao diện recorder trước khi lưu lời nhắn.';

  @override
  String get memoryFormCancelRecording => 'Hủy ghi âm';

  @override
  String get memoryFormSaveVoice => 'Lưu lời nhắn';

  @override
  String memoryFormImportedAudioTitle(int number) {
    return 'Audio từ máy $number';
  }

  @override
  String memoryFormRecordedVoiceTitle(int number) {
    return 'Lời nhắn ghi âm $number';
  }

  @override
  String get memoryFormAddMediaTitle => 'Thêm media';

  @override
  String get memoryFormAddPhoto => 'Thêm ảnh từ thư viện';

  @override
  String get memoryFormAddPhotoSubtitle =>
      'Mock bằng ảnh hero, sau này nối image picker.';

  @override
  String get memoryFormAddVideo => 'Thêm video từ thư viện';

  @override
  String get memoryFormAddVideoSubtitle =>
      'Mock bằng thumbnail hero, sau này nối video picker.';

  @override
  String get memoryFormCamera => 'Chụp hoặc quay mới';

  @override
  String get memoryFormCameraSubtitle =>
      'Sẽ mở camera khi có permission native.';

  @override
  String get memoryFormVideoMockAlt => 'Video mock';

  @override
  String get memoryFormImageMockAlt => 'Ảnh mock';

  @override
  String get memoryFormBodyRequired =>
      'Hãy thêm mô tả, ghi chú, lời nhắn hoặc ít nhất một ảnh/video.';

  @override
  String get memoryFormTitleLabel => 'Tiêu đề';

  @override
  String get memoryFormTitleHint => 'Đặt tên cho khoảnh khắc này';

  @override
  String get memoryFormTitleRequired => 'Tiêu đề là bắt buộc';

  @override
  String get memoryFormDescriptionLabel => 'Mô tả';

  @override
  String get memoryFormDescriptionHint => 'Viết ngắn về điều đã xảy ra...';

  @override
  String get memoryFormDateLabel => 'Thời gian';

  @override
  String get memoryFormLocationLabel => 'Địa điểm';

  @override
  String get memoryFormLocationHint => 'Thêm nơi hai đứa đã đi qua';

  @override
  String get memoryFormNoteLabel => 'Ghi chú';

  @override
  String get memoryFormNoteHint => 'Một điều nhỏ muốn nhớ riêng';

  @override
  String get memoryFormNoVoiceTitle => 'Chưa có lời nhắn';

  @override
  String get memoryFormNoVoiceBody =>
      'Ghi âm mới hoặc chọn một đoạn audio có sẵn trong máy.';

  @override
  String get memoryFormAddVoiceCta => 'Thêm lời nhắn';

  @override
  String get memoryFormVoiceLimitReached => 'Đã đạt giới hạn lời nhắn';

  @override
  String get memoryFormVoiceFallbackTitle => 'Lời nhắn';

  @override
  String get memoryFormRecordedSource => 'Ghi âm';

  @override
  String get memoryFormImportedSource => 'Từ máy';

  @override
  String memoryFormVoiceSourceAndDuration(String source, String duration) {
    return '$source · $duration';
  }

  @override
  String get memoryFormDeleteVoiceTooltip => 'Xóa lời nhắn';

  @override
  String get memoryFormTagSection => 'Nhãn kỷ niệm';

  @override
  String get memoryFormCreateTagChip => '+ Tạo nhãn';

  @override
  String get memoryFormMediaGroupsSection => 'Nhóm media';

  @override
  String memoryFormGroupLimit(int current, int max) {
    return '$current/$max nhóm';
  }

  @override
  String get memoryFormMediaGroupsHelper =>
      'Tạo tối đa 3 nhóm để kể chuyện theo từng đoạn.';

  @override
  String get memoryFormNoMediaGroupTitle => 'Chưa có nhóm media';

  @override
  String get memoryFormNoMediaGroupBody =>
      'Tạo nhóm đầu tiên rồi thêm ảnh/video vào đoạn câu chuyện đó.';

  @override
  String get memoryFormAddMediaGroup => 'Thêm nhóm media';

  @override
  String memoryFormMediaGroupTitle(int current, int max) {
    return 'Nhóm media · $current/$max';
  }

  @override
  String get memoryFormMediaGroupHelper =>
      'Ảnh và video cùng một đoạn câu chuyện';

  @override
  String get memoryFormMoveUp => 'Đưa lên trên';

  @override
  String get memoryFormMoveDown => 'Đưa xuống dưới';

  @override
  String get memoryFormDeleteGroup => 'Xóa nhóm';

  @override
  String get memoryFormGroupNoteHint => 'Note cho nhóm này, có thể bỏ trống';

  @override
  String memoryFormItemCount(int count) {
    return '$count mục';
  }

  @override
  String get memoryFormGroupsReorderHint => 'Có thể sắp xếp nhóm';

  @override
  String get memoryFormAddGroupToContinue => 'Thêm nhóm để kể tiếp';

  @override
  String get memoryFormGroupLimitReachedTitle => 'Đã đạt giới hạn nhóm';

  @override
  String get memoryFormAddAnotherMediaGroupTitle => 'Thêm một nhóm media khác';

  @override
  String get memoryFormGroupLimitReachedBody =>
      'Bạn có thể xóa một nhóm để tạo lại.';

  @override
  String get memoryFormAddAnotherMediaGroupBody =>
      'Mỗi nhóm có note riêng và có thể chứa ảnh/video hỗn hợp.';

  @override
  String get memoryFormGroupLimitReachedCta => 'Đã đạt giới hạn nhóm';
}
