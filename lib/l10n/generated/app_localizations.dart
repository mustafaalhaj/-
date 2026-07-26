import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
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
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
    Locale('fr'),
  ];

  /// No description provided for @appName.
  ///
  /// In ar, this message translates to:
  /// **'أنا مسلم'**
  String get appName;

  /// No description provided for @settingsTitle.
  ///
  /// In ar, this message translates to:
  /// **'الإعدادات'**
  String get settingsTitle;

  /// No description provided for @appearanceSection.
  ///
  /// In ar, this message translates to:
  /// **'المظهر'**
  String get appearanceSection;

  /// No description provided for @darkMode.
  ///
  /// In ar, this message translates to:
  /// **'الوضع الليلي'**
  String get darkMode;

  /// No description provided for @darkModeSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'تفعيل المظهر الداكن للتطبيق'**
  String get darkModeSubtitle;

  /// No description provided for @fontSize.
  ///
  /// In ar, this message translates to:
  /// **'حجم الخط'**
  String get fontSize;

  /// No description provided for @notificationsAndTimesSection.
  ///
  /// In ar, this message translates to:
  /// **'الإعدادات والمواقيت'**
  String get notificationsAndTimesSection;

  /// No description provided for @prayerAlerts.
  ///
  /// In ar, this message translates to:
  /// **'تنبيهات الصلاة'**
  String get prayerAlerts;

  /// No description provided for @prayerAlertsSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'تلقي إشعارات عند دخول وقت الصلاة'**
  String get prayerAlertsSubtitle;

  /// No description provided for @advancedPrayerSettings.
  ///
  /// In ar, this message translates to:
  /// **'إعدادات المواقيت المتقدمة'**
  String get advancedPrayerSettings;

  /// No description provided for @advancedPrayerSettingsSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'تعديل طريقة الحساب والمذهب والموقع'**
  String get advancedPrayerSettingsSubtitle;

  /// No description provided for @aboutAppSection.
  ///
  /// In ar, this message translates to:
  /// **'حول التطبيق'**
  String get aboutAppSection;

  /// No description provided for @version.
  ///
  /// In ar, this message translates to:
  /// **'الإصدار'**
  String get version;

  /// No description provided for @developer.
  ///
  /// In ar, this message translates to:
  /// **'المطور'**
  String get developer;

  /// No description provided for @developerSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'Al Haj Mustafa - تابعني على إنستغرام'**
  String get developerSubtitle;

  /// No description provided for @supportSection.
  ///
  /// In ar, this message translates to:
  /// **'الدعم'**
  String get supportSection;

  /// No description provided for @rateApp.
  ///
  /// In ar, this message translates to:
  /// **'تقييم التطبيق'**
  String get rateApp;

  /// No description provided for @rateAppSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'ساعدنا بتقييم التطبيق على المتجر'**
  String get rateAppSubtitle;

  /// No description provided for @shareApp.
  ///
  /// In ar, this message translates to:
  /// **'مشاركة التطبيق'**
  String get shareApp;

  /// No description provided for @shareAppSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'شارك التطبيق مع أصدقائك'**
  String get shareAppSubtitle;

  /// No description provided for @madeWithLove.
  ///
  /// In ar, this message translates to:
  /// **'صنع بحب ❤️'**
  String get madeWithLove;

  /// No description provided for @small.
  ///
  /// In ar, this message translates to:
  /// **'صغير'**
  String get small;

  /// No description provided for @medium.
  ///
  /// In ar, this message translates to:
  /// **'متوسط'**
  String get medium;

  /// No description provided for @large.
  ///
  /// In ar, this message translates to:
  /// **'كبير'**
  String get large;

  /// No description provided for @veryLarge.
  ///
  /// In ar, this message translates to:
  /// **'كبير جداً'**
  String get veryLarge;

  /// No description provided for @themeSection.
  ///
  /// In ar, this message translates to:
  /// **'الثيم'**
  String get themeSection;

  /// No description provided for @currentTheme.
  ///
  /// In ar, this message translates to:
  /// **'الثيم الحالي'**
  String get currentTheme;

  /// No description provided for @lightTheme.
  ///
  /// In ar, this message translates to:
  /// **'فاتح'**
  String get lightTheme;

  /// No description provided for @darkTheme.
  ///
  /// In ar, this message translates to:
  /// **'داكن'**
  String get darkTheme;

  /// No description provided for @fajrTheme.
  ///
  /// In ar, this message translates to:
  /// **'الفجر'**
  String get fajrTheme;

  /// No description provided for @kaabaTheme.
  ///
  /// In ar, this message translates to:
  /// **'الكعبة'**
  String get kaabaTheme;

  /// No description provided for @chooseTheme.
  ///
  /// In ar, this message translates to:
  /// **'اختر الثيم'**
  String get chooseTheme;

  /// No description provided for @quran.
  ///
  /// In ar, this message translates to:
  /// **'القرآن الكريم'**
  String get quran;

  /// No description provided for @prayerTimes.
  ///
  /// In ar, this message translates to:
  /// **'مواقيت الصلاة'**
  String get prayerTimes;

  /// No description provided for @adhkar.
  ///
  /// In ar, this message translates to:
  /// **'الأذكار'**
  String get adhkar;

  /// No description provided for @hadith.
  ///
  /// In ar, this message translates to:
  /// **'الحديث الشريف'**
  String get hadith;

  /// No description provided for @qibla.
  ///
  /// In ar, this message translates to:
  /// **'القبلة'**
  String get qibla;

  /// No description provided for @tasbih.
  ///
  /// In ar, this message translates to:
  /// **'السبحة'**
  String get tasbih;

  /// No description provided for @asmaulHusna.
  ///
  /// In ar, this message translates to:
  /// **'أسماء الله الحسنى'**
  String get asmaulHusna;

  /// No description provided for @duas.
  ///
  /// In ar, this message translates to:
  /// **'الأدعية'**
  String get duas;

  /// No description provided for @aiChat.
  ///
  /// In ar, this message translates to:
  /// **'المساعد الذكي'**
  String get aiChat;

  /// No description provided for @mood.
  ///
  /// In ar, this message translates to:
  /// **'حالتك النفسية'**
  String get mood;

  /// No description provided for @liveStream.
  ///
  /// In ar, this message translates to:
  /// **'بث مباشر'**
  String get liveStream;

  /// No description provided for @fastingTracker.
  ///
  /// In ar, this message translates to:
  /// **'صيامك'**
  String get fastingTracker;

  /// No description provided for @hijriCalendar.
  ///
  /// In ar, this message translates to:
  /// **'التقويم الهجري'**
  String get hijriCalendar;

  /// No description provided for @more.
  ///
  /// In ar, this message translates to:
  /// **'المزيد'**
  String get more;

  /// No description provided for @home.
  ///
  /// In ar, this message translates to:
  /// **'الرئيسية'**
  String get home;
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
      <String>['ar', 'en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
