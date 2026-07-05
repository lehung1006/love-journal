import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_vi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('vi')];

  /// No description provided for @appTitle.
  ///
  /// In vi, this message translates to:
  /// **'Mình & Em'**
  String get appTitle;

  /// No description provided for @navHome.
  ///
  /// In vi, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navTime.
  ///
  /// In vi, this message translates to:
  /// **'Time'**
  String get navTime;

  /// No description provided for @navMap.
  ///
  /// In vi, this message translates to:
  /// **'Map'**
  String get navMap;

  /// No description provided for @navLetters.
  ///
  /// In vi, this message translates to:
  /// **'Thư'**
  String get navLetters;

  /// No description provided for @backTooltip.
  ///
  /// In vi, this message translates to:
  /// **'Quay lại'**
  String get backTooltip;

  /// No description provided for @saveTooltip.
  ///
  /// In vi, this message translates to:
  /// **'Lưu'**
  String get saveTooltip;

  /// No description provided for @favoriteTooltip.
  ///
  /// In vi, this message translates to:
  /// **'Yêu thích'**
  String get favoriteTooltip;

  /// No description provided for @cancelAction.
  ///
  /// In vi, this message translates to:
  /// **'Hủy'**
  String get cancelAction;

  /// No description provided for @deleteAction.
  ///
  /// In vi, this message translates to:
  /// **'Xóa'**
  String get deleteAction;

  /// No description provided for @understoodAction.
  ///
  /// In vi, this message translates to:
  /// **'Đã hiểu'**
  String get understoodAction;

  /// No description provided for @openingKicker.
  ///
  /// In vi, this message translates to:
  /// **'Gửi riêng em'**
  String get openingKicker;

  /// No description provided for @openingTitle.
  ///
  /// In vi, this message translates to:
  /// **'Ba năm, mình vẫn ở đây.'**
  String get openingTitle;

  /// No description provided for @openingBody.
  ///
  /// In vi, this message translates to:
  /// **'Anh gói lại vài nơi mình đã đi qua, vài ngày mình đã thương nhau, và một lời hẹn thật nhỏ cho chặng sau.'**
  String get openingBody;

  /// No description provided for @openingCta.
  ///
  /// In vi, this message translates to:
  /// **'Mở món quà'**
  String get openingCta;

  /// No description provided for @homeKicker.
  ///
  /// In vi, this message translates to:
  /// **'Chào em'**
  String get homeKicker;

  /// No description provided for @homeRecapTooltip.
  ///
  /// In vi, this message translates to:
  /// **'Kỷ niệm 3 năm'**
  String get homeRecapTooltip;

  /// No description provided for @homeHeroKicker.
  ///
  /// In vi, this message translates to:
  /// **'Kỷ niệm của tụi mình'**
  String get homeHeroKicker;

  /// No description provided for @homeLoveDays.
  ///
  /// In vi, this message translates to:
  /// **'{days} ngày yêu'**
  String homeLoveDays(String days);

  /// No description provided for @homeHeroSubtitle.
  ///
  /// In vi, this message translates to:
  /// **'Và anh vẫn muốn đi tiếp cùng em.'**
  String get homeHeroSubtitle;

  /// No description provided for @homeMemoriesWritten.
  ///
  /// In vi, this message translates to:
  /// **'kỷ niệm đã viết'**
  String get homeMemoriesWritten;

  /// No description provided for @homePlacesVisited.
  ///
  /// In vi, this message translates to:
  /// **'nơi mình đã qua'**
  String get homePlacesVisited;

  /// No description provided for @homeFeaturedMemory.
  ///
  /// In vi, this message translates to:
  /// **'Kỷ niệm nổi bật'**
  String get homeFeaturedMemory;

  /// No description provided for @homeNoFeaturedTitle.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có kỷ niệm nổi bật'**
  String get homeNoFeaturedTitle;

  /// No description provided for @homeNoFeaturedBody.
  ///
  /// In vi, this message translates to:
  /// **'Khi thêm kỷ niệm đầu tiên, Home sẽ giữ lại khoảnh khắc đáng nhớ nhất ở đây.'**
  String get homeNoFeaturedBody;

  /// No description provided for @homeNextLetter.
  ///
  /// In vi, this message translates to:
  /// **'Lá thư tiếp theo'**
  String get homeNextLetter;

  /// No description provided for @homeNoLettersTitle.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có lá thư nào'**
  String get homeNoLettersTitle;

  /// No description provided for @homeNoLettersBody.
  ///
  /// In vi, this message translates to:
  /// **'Khi có thư mới, Home sẽ luôn giữ một lời nhắn gần nhất.'**
  String get homeNoLettersBody;

  /// No description provided for @homeRecapCta.
  ///
  /// In vi, this message translates to:
  /// **'Xem recap ba năm'**
  String get homeRecapCta;

  /// No description provided for @timelineKicker.
  ///
  /// In vi, this message translates to:
  /// **'Theo dòng thời gian'**
  String get timelineKicker;

  /// No description provided for @timelineTitle.
  ///
  /// In vi, this message translates to:
  /// **'Time'**
  String get timelineTitle;

  /// No description provided for @timelineSearchTooltip.
  ///
  /// In vi, this message translates to:
  /// **'Tìm kỷ niệm'**
  String get timelineSearchTooltip;

  /// No description provided for @timelineAddMemoryTooltip.
  ///
  /// In vi, this message translates to:
  /// **'Thêm kỷ niệm'**
  String get timelineAddMemoryTooltip;

  /// No description provided for @timelineAllYears.
  ///
  /// In vi, this message translates to:
  /// **'Tất cả năm'**
  String get timelineAllYears;

  /// No description provided for @timelineAllFilter.
  ///
  /// In vi, this message translates to:
  /// **'Tất cả'**
  String get timelineAllFilter;

  /// No description provided for @timelineEmptyTitle.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có kỷ niệm nào được viết'**
  String get timelineEmptyTitle;

  /// No description provided for @timelineEmptyBody.
  ///
  /// In vi, this message translates to:
  /// **'Bắt đầu bằng một khoảnh khắc nhỏ. Một buổi tối bình thường cũng xứng đáng được giữ lại.'**
  String get timelineEmptyBody;

  /// No description provided for @timelineEmptyCta.
  ///
  /// In vi, this message translates to:
  /// **'Thêm kỷ niệm đầu tiên'**
  String get timelineEmptyCta;

  /// No description provided for @timelineFilteredEmptyTitle.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có kỷ niệm trong nhãn này'**
  String get timelineFilteredEmptyTitle;

  /// No description provided for @timelineFilteredEmptyBody.
  ///
  /// In vi, this message translates to:
  /// **'Bạn có thể thêm một kỷ niệm mới vào nhãn đang chọn.'**
  String get timelineFilteredEmptyBody;

  /// No description provided for @timelineFilteredEmptyCta.
  ///
  /// In vi, this message translates to:
  /// **'Thêm vào nhãn này'**
  String get timelineFilteredEmptyCta;

  /// No description provided for @timelineMemoryActionHelper.
  ///
  /// In vi, this message translates to:
  /// **'Chọn cách chỉnh sửa kỷ niệm này.'**
  String get timelineMemoryActionHelper;

  /// No description provided for @timelineEditMemory.
  ///
  /// In vi, this message translates to:
  /// **'Sửa kỷ niệm'**
  String get timelineEditMemory;

  /// No description provided for @timelineFeatureMemory.
  ///
  /// In vi, this message translates to:
  /// **'Đặt làm kỷ niệm nổi bật'**
  String get timelineFeatureMemory;

  /// No description provided for @timelineDeleteMemory.
  ///
  /// In vi, this message translates to:
  /// **'Xóa kỷ niệm'**
  String get timelineDeleteMemory;

  /// No description provided for @timelineDeleteTitle.
  ///
  /// In vi, this message translates to:
  /// **'Xóa kỷ niệm?'**
  String get timelineDeleteTitle;

  /// No description provided for @timelineDeleteBody.
  ///
  /// In vi, this message translates to:
  /// **'“{title}” sẽ được ẩn khỏi Time. Sau này có thể thêm thùng khôi phục khi có tài khoản/sync.'**
  String timelineDeleteBody(String title);

  /// No description provided for @memoryOptionsTooltip.
  ///
  /// In vi, this message translates to:
  /// **'Tùy chọn kỷ niệm'**
  String get memoryOptionsTooltip;

  /// No description provided for @timelineFallbackEmptyBody.
  ///
  /// In vi, this message translates to:
  /// **'Khi có dữ liệu, timeline sẽ hiện theo thứ tự thời gian.'**
  String get timelineFallbackEmptyBody;

  /// No description provided for @mediaSummaryImages.
  ///
  /// In vi, this message translates to:
  /// **'{count} ảnh'**
  String mediaSummaryImages(int count);

  /// No description provided for @mediaSummaryVideos.
  ///
  /// In vi, this message translates to:
  /// **'{count} video'**
  String mediaSummaryVideos(int count);

  /// No description provided for @mediaSummaryVoiceMessages.
  ///
  /// In vi, this message translates to:
  /// **'{count} lời nhắn'**
  String mediaSummaryVoiceMessages(int count);

  /// No description provided for @mediaSummaryEmpty.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có media'**
  String get mediaSummaryEmpty;

  /// No description provided for @categoryTrip.
  ///
  /// In vi, this message translates to:
  /// **'Chuyến đi'**
  String get categoryTrip;

  /// No description provided for @categoryBirthday.
  ///
  /// In vi, this message translates to:
  /// **'Sinh nhật'**
  String get categoryBirthday;

  /// No description provided for @categoryDaily.
  ///
  /// In vi, this message translates to:
  /// **'Đời thường'**
  String get categoryDaily;

  /// No description provided for @categoryMilestone.
  ///
  /// In vi, this message translates to:
  /// **'Dấu mốc'**
  String get categoryMilestone;

  /// No description provided for @categoryAnniversary.
  ///
  /// In vi, this message translates to:
  /// **'Kỷ niệm'**
  String get categoryAnniversary;

  /// No description provided for @phaseYear1.
  ///
  /// In vi, this message translates to:
  /// **'Năm đầu tiên'**
  String get phaseYear1;

  /// No description provided for @phaseYear2.
  ///
  /// In vi, this message translates to:
  /// **'Năm thứ hai'**
  String get phaseYear2;

  /// No description provided for @phaseYear3.
  ///
  /// In vi, this message translates to:
  /// **'Năm thứ ba'**
  String get phaseYear3;

  /// No description provided for @mapKicker.
  ///
  /// In vi, this message translates to:
  /// **'Những nơi mình qua'**
  String get mapKicker;

  /// No description provided for @mapTitle.
  ///
  /// In vi, this message translates to:
  /// **'Bản đồ'**
  String get mapTitle;

  /// No description provided for @mapLocationTooltip.
  ///
  /// In vi, this message translates to:
  /// **'Địa điểm'**
  String get mapLocationTooltip;

  /// No description provided for @mapRecenterTooltip.
  ///
  /// In vi, this message translates to:
  /// **'Đưa về những nơi đã lưu'**
  String get mapRecenterTooltip;

  /// No description provided for @mapSearchHint.
  ///
  /// In vi, this message translates to:
  /// **'Tìm địa điểm'**
  String get mapSearchHint;

  /// No description provided for @mapSearchDisabledHint.
  ///
  /// In vi, this message translates to:
  /// **'Thêm API key để tìm địa điểm'**
  String get mapSearchDisabledHint;

  /// No description provided for @mapSearchClearTooltip.
  ///
  /// In vi, this message translates to:
  /// **'Xóa tìm kiếm'**
  String get mapSearchClearTooltip;

  /// No description provided for @mapSearchLoading.
  ///
  /// In vi, this message translates to:
  /// **'Đang tìm nơi này...'**
  String get mapSearchLoading;

  /// No description provided for @mapSearchEmpty.
  ///
  /// In vi, this message translates to:
  /// **'Không tìm thấy địa điểm phù hợp'**
  String get mapSearchEmpty;

  /// No description provided for @mapSearchError.
  ///
  /// In vi, this message translates to:
  /// **'Chưa tìm được địa điểm. Thử lại sau nhé.'**
  String get mapSearchError;

  /// No description provided for @mapSearchPoweredByGoogle.
  ///
  /// In vi, this message translates to:
  /// **'Kết quả từ Google Places'**
  String get mapSearchPoweredByGoogle;

  /// No description provided for @mapApiKeyMissingTitle.
  ///
  /// In vi, this message translates to:
  /// **'Chưa cấu hình Google Maps'**
  String get mapApiKeyMissingTitle;

  /// No description provided for @mapApiKeyMissingBody.
  ///
  /// In vi, this message translates to:
  /// **'Thêm GOOGLE_MAPS_API_KEY cho Android/iOS và dart-define để bật bản đồ thật cùng tìm địa điểm.'**
  String get mapApiKeyMissingBody;

  /// No description provided for @mapSavedPlacesTitle.
  ///
  /// In vi, this message translates to:
  /// **'Những nơi đã lưu'**
  String get mapSavedPlacesTitle;

  /// No description provided for @mapSavedPlaceMemoryCount.
  ///
  /// In vi, this message translates to:
  /// **'{count} kỷ niệm'**
  String mapSavedPlaceMemoryCount(int count);

  /// No description provided for @mapSelectedPlaceTitle.
  ///
  /// In vi, this message translates to:
  /// **'Địa điểm tìm thấy'**
  String get mapSelectedPlaceTitle;

  /// No description provided for @mapSelectedPlaceBody.
  ///
  /// In vi, this message translates to:
  /// **'Sau này có thể gắn nơi này vào kỷ niệm mới hoặc thêm ghi chú riêng.'**
  String get mapSelectedPlaceBody;

  /// No description provided for @mapSelectedPlaceAddressFallback.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có địa chỉ chi tiết'**
  String get mapSelectedPlaceAddressFallback;

  /// No description provided for @mapSelectedPlaceCloseTooltip.
  ///
  /// In vi, this message translates to:
  /// **'Đóng địa điểm đang chọn'**
  String get mapSelectedPlaceCloseTooltip;

  /// No description provided for @mapNoPlacesTitle.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có nơi nào được lưu'**
  String get mapNoPlacesTitle;

  /// No description provided for @mapNoPlacesBody.
  ///
  /// In vi, this message translates to:
  /// **'Khi kỷ niệm có địa điểm, Map sẽ gom chúng thành những dấu mốc trên hành trình.'**
  String get mapNoPlacesBody;

  /// No description provided for @placeMemorySummary.
  ///
  /// In vi, this message translates to:
  /// **'{count} kỷ niệm · {note}'**
  String placeMemorySummary(int count, String note);

  /// No description provided for @placeOpenMemories.
  ///
  /// In vi, this message translates to:
  /// **'Xem kỷ niệm'**
  String get placeOpenMemories;

  /// No description provided for @lettersKicker.
  ///
  /// In vi, this message translates to:
  /// **'Dành cho em'**
  String get lettersKicker;

  /// No description provided for @lettersTitle.
  ///
  /// In vi, this message translates to:
  /// **'Những lá thư'**
  String get lettersTitle;

  /// No description provided for @lettersTooltip.
  ///
  /// In vi, this message translates to:
  /// **'Thư'**
  String get lettersTooltip;

  /// No description provided for @letterReservedDay.
  ///
  /// In vi, this message translates to:
  /// **'Một ngày được để dành'**
  String get letterReservedDay;

  /// No description provided for @letterOpensOn.
  ///
  /// In vi, this message translates to:
  /// **'Mở vào {date}'**
  String letterOpensOn(String date);

  /// No description provided for @letterLockedNoDateBody.
  ///
  /// In vi, this message translates to:
  /// **'Lá thư này đang được giữ lại cho đúng khoảnh khắc.'**
  String get letterLockedNoDateBody;

  /// No description provided for @letterLockedRemainingBody.
  ///
  /// In vi, this message translates to:
  /// **'Còn {days} ngày nữa lá thư này mới mở được.'**
  String letterLockedRemainingBody(int days);

  /// No description provided for @letterOpened.
  ///
  /// In vi, this message translates to:
  /// **'Đã mở'**
  String get letterOpened;

  /// No description provided for @letterReady.
  ///
  /// In vi, this message translates to:
  /// **'Đã sẵn sàng'**
  String get letterReady;

  /// No description provided for @letterDaysRemaining.
  ///
  /// In vi, this message translates to:
  /// **'Còn {days} ngày'**
  String letterDaysRemaining(int days);

  /// No description provided for @letterDetailToday.
  ///
  /// In vi, this message translates to:
  /// **'Mở vào hôm nay'**
  String get letterDetailToday;

  /// No description provided for @letterKeepTooltip.
  ///
  /// In vi, this message translates to:
  /// **'Giữ lá thư'**
  String get letterKeepTooltip;

  /// No description provided for @letterKeepCta.
  ///
  /// In vi, this message translates to:
  /// **'Giữ lá thư này'**
  String get letterKeepCta;

  /// No description provided for @memoryDetailMomentMessage.
  ///
  /// In vi, this message translates to:
  /// **'Lời nhắn cho khoảnh khắc này'**
  String get memoryDetailMomentMessage;

  /// No description provided for @recapKicker.
  ///
  /// In vi, this message translates to:
  /// **'Kỷ niệm 3 năm'**
  String get recapKicker;

  /// No description provided for @recapTitle.
  ///
  /// In vi, this message translates to:
  /// **'Mình đã đi qua thật nhiều.'**
  String get recapTitle;

  /// No description provided for @recapSubtitle.
  ///
  /// In vi, this message translates to:
  /// **'Và anh vẫn muốn đi tiếp cùng em.'**
  String get recapSubtitle;

  /// No description provided for @recapDaysLoved.
  ///
  /// In vi, this message translates to:
  /// **'ngày yêu'**
  String get recapDaysLoved;

  /// No description provided for @recapPlacesVisited.
  ///
  /// In vi, this message translates to:
  /// **'nơi đã qua'**
  String get recapPlacesVisited;

  /// No description provided for @recapPhotos.
  ///
  /// In vi, this message translates to:
  /// **'tấm ảnh'**
  String get recapPhotos;

  /// No description provided for @recapLetters.
  ///
  /// In vi, this message translates to:
  /// **'lá thư'**
  String get recapLetters;

  /// No description provided for @recapQuote.
  ///
  /// In vi, this message translates to:
  /// **'Ba năm không phải là điểm kết. Nó là bằng chứng rằng mình đã chọn nhau, rất nhiều lần.'**
  String get recapQuote;

  /// No description provided for @recapCta.
  ///
  /// In vi, this message translates to:
  /// **'Cùng anh viết tiếp nhé?'**
  String get recapCta;

  /// No description provided for @routerUnknownError.
  ///
  /// In vi, this message translates to:
  /// **'Unknown error'**
  String get routerUnknownError;

  /// No description provided for @routerMissingParam.
  ///
  /// In vi, this message translates to:
  /// **'Missing route parameter: {name}'**
  String routerMissingParam(String name);

  /// No description provided for @routerErrorTitle.
  ///
  /// In vi, this message translates to:
  /// **'Chưa mở được nhật ký'**
  String get routerErrorTitle;

  /// No description provided for @memoryFormNewTitle.
  ///
  /// In vi, this message translates to:
  /// **'Kỷ niệm mới'**
  String get memoryFormNewTitle;

  /// No description provided for @memoryFormEditTitle.
  ///
  /// In vi, this message translates to:
  /// **'Sửa kỷ niệm'**
  String get memoryFormEditTitle;

  /// No description provided for @memoryFormSave.
  ///
  /// In vi, this message translates to:
  /// **'Lưu kỷ niệm'**
  String get memoryFormSave;

  /// No description provided for @memoryFormSaving.
  ///
  /// In vi, this message translates to:
  /// **'Đang lưu...'**
  String get memoryFormSaving;

  /// No description provided for @memoryFormCreateTagTitle.
  ///
  /// In vi, this message translates to:
  /// **'Tạo nhãn mới'**
  String get memoryFormCreateTagTitle;

  /// No description provided for @memoryFormCreateTagHint.
  ///
  /// In vi, this message translates to:
  /// **'Ví dụ: Cafe tối'**
  String get memoryFormCreateTagHint;

  /// No description provided for @memoryFormSaveTag.
  ///
  /// In vi, this message translates to:
  /// **'Lưu nhãn'**
  String get memoryFormSaveTag;

  /// No description provided for @memoryFormAddVoiceTitle.
  ///
  /// In vi, this message translates to:
  /// **'Thêm lời nhắn'**
  String get memoryFormAddVoiceTitle;

  /// No description provided for @memoryFormAddVoiceHelper.
  ///
  /// In vi, this message translates to:
  /// **'Chọn một file có sẵn hoặc ghi âm ngay trong app.'**
  String get memoryFormAddVoiceHelper;

  /// No description provided for @memoryFormPickFromDevice.
  ///
  /// In vi, this message translates to:
  /// **'Chọn từ máy'**
  String get memoryFormPickFromDevice;

  /// No description provided for @memoryFormPickAudioSubtitle.
  ///
  /// In vi, this message translates to:
  /// **'MVP sẽ thay mock này bằng file picker native.'**
  String get memoryFormPickAudioSubtitle;

  /// No description provided for @memoryFormRecordNew.
  ///
  /// In vi, this message translates to:
  /// **'Ghi âm mới'**
  String get memoryFormRecordNew;

  /// No description provided for @memoryFormRecordSubtitle.
  ///
  /// In vi, this message translates to:
  /// **'Mở giao diện recorder trước khi lưu lời nhắn.'**
  String get memoryFormRecordSubtitle;

  /// No description provided for @memoryFormCancelRecording.
  ///
  /// In vi, this message translates to:
  /// **'Hủy ghi âm'**
  String get memoryFormCancelRecording;

  /// No description provided for @memoryFormSaveVoice.
  ///
  /// In vi, this message translates to:
  /// **'Lưu lời nhắn'**
  String get memoryFormSaveVoice;

  /// No description provided for @memoryFormImportedAudioTitle.
  ///
  /// In vi, this message translates to:
  /// **'Audio từ máy {number}'**
  String memoryFormImportedAudioTitle(int number);

  /// No description provided for @memoryFormRecordedVoiceTitle.
  ///
  /// In vi, this message translates to:
  /// **'Lời nhắn ghi âm {number}'**
  String memoryFormRecordedVoiceTitle(int number);

  /// No description provided for @memoryFormAddMediaTitle.
  ///
  /// In vi, this message translates to:
  /// **'Thêm media'**
  String get memoryFormAddMediaTitle;

  /// No description provided for @memoryFormAddPhoto.
  ///
  /// In vi, this message translates to:
  /// **'Thêm ảnh từ thư viện'**
  String get memoryFormAddPhoto;

  /// No description provided for @memoryFormAddPhotoSubtitle.
  ///
  /// In vi, this message translates to:
  /// **'Mock bằng ảnh hero, sau này nối image picker.'**
  String get memoryFormAddPhotoSubtitle;

  /// No description provided for @memoryFormAddVideo.
  ///
  /// In vi, this message translates to:
  /// **'Thêm video từ thư viện'**
  String get memoryFormAddVideo;

  /// No description provided for @memoryFormAddVideoSubtitle.
  ///
  /// In vi, this message translates to:
  /// **'Mock bằng thumbnail hero, sau này nối video picker.'**
  String get memoryFormAddVideoSubtitle;

  /// No description provided for @memoryFormCamera.
  ///
  /// In vi, this message translates to:
  /// **'Chụp hoặc quay mới'**
  String get memoryFormCamera;

  /// No description provided for @memoryFormCameraSubtitle.
  ///
  /// In vi, this message translates to:
  /// **'Sẽ mở camera khi có permission native.'**
  String get memoryFormCameraSubtitle;

  /// No description provided for @memoryFormVideoMockAlt.
  ///
  /// In vi, this message translates to:
  /// **'Video mock'**
  String get memoryFormVideoMockAlt;

  /// No description provided for @memoryFormImageMockAlt.
  ///
  /// In vi, this message translates to:
  /// **'Ảnh mock'**
  String get memoryFormImageMockAlt;

  /// No description provided for @memoryFormBodyRequired.
  ///
  /// In vi, this message translates to:
  /// **'Hãy thêm mô tả, ghi chú, lời nhắn hoặc ít nhất một ảnh/video.'**
  String get memoryFormBodyRequired;

  /// No description provided for @memoryFormTitleLabel.
  ///
  /// In vi, this message translates to:
  /// **'Tiêu đề'**
  String get memoryFormTitleLabel;

  /// No description provided for @memoryFormTitleHint.
  ///
  /// In vi, this message translates to:
  /// **'Đặt tên cho khoảnh khắc này'**
  String get memoryFormTitleHint;

  /// No description provided for @memoryFormTitleRequired.
  ///
  /// In vi, this message translates to:
  /// **'Tiêu đề là bắt buộc'**
  String get memoryFormTitleRequired;

  /// No description provided for @memoryFormDescriptionLabel.
  ///
  /// In vi, this message translates to:
  /// **'Mô tả'**
  String get memoryFormDescriptionLabel;

  /// No description provided for @memoryFormDescriptionHint.
  ///
  /// In vi, this message translates to:
  /// **'Viết ngắn về điều đã xảy ra...'**
  String get memoryFormDescriptionHint;

  /// No description provided for @memoryFormDateLabel.
  ///
  /// In vi, this message translates to:
  /// **'Thời gian'**
  String get memoryFormDateLabel;

  /// No description provided for @memoryFormLocationLabel.
  ///
  /// In vi, this message translates to:
  /// **'Địa điểm'**
  String get memoryFormLocationLabel;

  /// No description provided for @memoryFormLocationHint.
  ///
  /// In vi, this message translates to:
  /// **'Thêm nơi hai đứa đã đi qua'**
  String get memoryFormLocationHint;

  /// No description provided for @memoryFormNoteLabel.
  ///
  /// In vi, this message translates to:
  /// **'Ghi chú'**
  String get memoryFormNoteLabel;

  /// No description provided for @memoryFormNoteHint.
  ///
  /// In vi, this message translates to:
  /// **'Một điều nhỏ muốn nhớ riêng'**
  String get memoryFormNoteHint;

  /// No description provided for @memoryFormNoVoiceTitle.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có lời nhắn'**
  String get memoryFormNoVoiceTitle;

  /// No description provided for @memoryFormNoVoiceBody.
  ///
  /// In vi, this message translates to:
  /// **'Ghi âm mới hoặc chọn một đoạn audio có sẵn trong máy.'**
  String get memoryFormNoVoiceBody;

  /// No description provided for @memoryFormAddVoiceCta.
  ///
  /// In vi, this message translates to:
  /// **'Thêm lời nhắn'**
  String get memoryFormAddVoiceCta;

  /// No description provided for @memoryFormVoiceLimitReached.
  ///
  /// In vi, this message translates to:
  /// **'Đã đạt giới hạn lời nhắn'**
  String get memoryFormVoiceLimitReached;

  /// No description provided for @memoryFormVoiceFallbackTitle.
  ///
  /// In vi, this message translates to:
  /// **'Lời nhắn'**
  String get memoryFormVoiceFallbackTitle;

  /// No description provided for @memoryFormRecordedSource.
  ///
  /// In vi, this message translates to:
  /// **'Ghi âm'**
  String get memoryFormRecordedSource;

  /// No description provided for @memoryFormImportedSource.
  ///
  /// In vi, this message translates to:
  /// **'Từ máy'**
  String get memoryFormImportedSource;

  /// No description provided for @memoryFormVoiceSourceAndDuration.
  ///
  /// In vi, this message translates to:
  /// **'{source} · {duration}'**
  String memoryFormVoiceSourceAndDuration(String source, String duration);

  /// No description provided for @memoryFormDeleteVoiceTooltip.
  ///
  /// In vi, this message translates to:
  /// **'Xóa lời nhắn'**
  String get memoryFormDeleteVoiceTooltip;

  /// No description provided for @memoryFormTagSection.
  ///
  /// In vi, this message translates to:
  /// **'Nhãn kỷ niệm'**
  String get memoryFormTagSection;

  /// No description provided for @memoryFormCreateTagChip.
  ///
  /// In vi, this message translates to:
  /// **'+ Tạo nhãn'**
  String get memoryFormCreateTagChip;

  /// No description provided for @memoryFormMediaGroupsSection.
  ///
  /// In vi, this message translates to:
  /// **'Nhóm media'**
  String get memoryFormMediaGroupsSection;

  /// No description provided for @memoryFormGroupLimit.
  ///
  /// In vi, this message translates to:
  /// **'{current}/{max} nhóm'**
  String memoryFormGroupLimit(int current, int max);

  /// No description provided for @memoryFormMediaGroupsHelper.
  ///
  /// In vi, this message translates to:
  /// **'Tạo tối đa 3 nhóm để kể chuyện theo từng đoạn.'**
  String get memoryFormMediaGroupsHelper;

  /// No description provided for @memoryFormNoMediaGroupTitle.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có nhóm media'**
  String get memoryFormNoMediaGroupTitle;

  /// No description provided for @memoryFormNoMediaGroupBody.
  ///
  /// In vi, this message translates to:
  /// **'Tạo nhóm đầu tiên rồi thêm ảnh/video vào đoạn câu chuyện đó.'**
  String get memoryFormNoMediaGroupBody;

  /// No description provided for @memoryFormAddMediaGroup.
  ///
  /// In vi, this message translates to:
  /// **'Thêm nhóm media'**
  String get memoryFormAddMediaGroup;

  /// No description provided for @memoryFormMediaGroupTitle.
  ///
  /// In vi, this message translates to:
  /// **'Nhóm media · {current}/{max}'**
  String memoryFormMediaGroupTitle(int current, int max);

  /// No description provided for @memoryFormMediaGroupHelper.
  ///
  /// In vi, this message translates to:
  /// **'Ảnh và video cùng một đoạn câu chuyện'**
  String get memoryFormMediaGroupHelper;

  /// No description provided for @memoryFormMoveUp.
  ///
  /// In vi, this message translates to:
  /// **'Đưa lên trên'**
  String get memoryFormMoveUp;

  /// No description provided for @memoryFormMoveDown.
  ///
  /// In vi, this message translates to:
  /// **'Đưa xuống dưới'**
  String get memoryFormMoveDown;

  /// No description provided for @memoryFormDeleteGroup.
  ///
  /// In vi, this message translates to:
  /// **'Xóa nhóm'**
  String get memoryFormDeleteGroup;

  /// No description provided for @memoryFormGroupNoteHint.
  ///
  /// In vi, this message translates to:
  /// **'Note cho nhóm này, có thể bỏ trống'**
  String get memoryFormGroupNoteHint;

  /// No description provided for @memoryFormItemCount.
  ///
  /// In vi, this message translates to:
  /// **'{count} mục'**
  String memoryFormItemCount(int count);

  /// No description provided for @memoryFormGroupsReorderHint.
  ///
  /// In vi, this message translates to:
  /// **'Có thể sắp xếp nhóm'**
  String get memoryFormGroupsReorderHint;

  /// No description provided for @memoryFormAddGroupToContinue.
  ///
  /// In vi, this message translates to:
  /// **'Thêm nhóm để kể tiếp'**
  String get memoryFormAddGroupToContinue;

  /// No description provided for @memoryFormGroupLimitReachedTitle.
  ///
  /// In vi, this message translates to:
  /// **'Đã đạt giới hạn nhóm'**
  String get memoryFormGroupLimitReachedTitle;

  /// No description provided for @memoryFormAddAnotherMediaGroupTitle.
  ///
  /// In vi, this message translates to:
  /// **'Thêm một nhóm media khác'**
  String get memoryFormAddAnotherMediaGroupTitle;

  /// No description provided for @memoryFormGroupLimitReachedBody.
  ///
  /// In vi, this message translates to:
  /// **'Bạn có thể xóa một nhóm để tạo lại.'**
  String get memoryFormGroupLimitReachedBody;

  /// No description provided for @memoryFormAddAnotherMediaGroupBody.
  ///
  /// In vi, this message translates to:
  /// **'Mỗi nhóm có note riêng và có thể chứa ảnh/video hỗn hợp.'**
  String get memoryFormAddAnotherMediaGroupBody;

  /// No description provided for @memoryFormGroupLimitReachedCta.
  ///
  /// In vi, this message translates to:
  /// **'Đã đạt giới hạn nhóm'**
  String get memoryFormGroupLimitReachedCta;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['vi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'vi':
      return AppLocalizationsVi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
