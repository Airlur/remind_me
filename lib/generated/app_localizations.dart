import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

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
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh')
  ];

  /// The application name
  ///
  /// In en, this message translates to:
  /// **'Remind Me'**
  String get appName;

  /// Bottom navigation bar date label
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// Bottom navigation bar time label
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get time;

  /// Bottom navigation bar settings label
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Settings page personalization item
  ///
  /// In en, this message translates to:
  /// **'Personalization'**
  String get personalization;

  /// Settings page notification item
  ///
  /// In en, this message translates to:
  /// **'Notification'**
  String get notification;

  /// Settings page help and feedback item
  ///
  /// In en, this message translates to:
  /// **'Help & Feedback'**
  String get helpAndFeedback;

  /// Settings page about item
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// Personalization page theme item
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// Theme follow system option
  ///
  /// In en, this message translates to:
  /// **'Follow System'**
  String get followSystem;

  /// Light theme mode
  ///
  /// In en, this message translates to:
  /// **'Light Mode'**
  String get lightMode;

  /// Dark theme mode
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// Personalization page language item
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// Personalization page date settings item
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get dateSettings;

  /// Personalization page animation background item
  ///
  /// In en, this message translates to:
  /// **'Animation Background'**
  String get animation;

  /// Personalization page widgets item
  ///
  /// In en, this message translates to:
  /// **'Widgets'**
  String get widgets;

  /// Notification page reminder notification item
  ///
  /// In en, this message translates to:
  /// **'Reminder Notification'**
  String get reminderNotification;

  /// Notification page sound item
  ///
  /// In en, this message translates to:
  /// **'Sound'**
  String get sound;

  /// Help and feedback page user help item
  ///
  /// In en, this message translates to:
  /// **'User Help'**
  String get userHelp;

  /// Help and feedback page feedback item
  ///
  /// In en, this message translates to:
  /// **'Feedback'**
  String get feedback;

  /// About page version info item
  ///
  /// In en, this message translates to:
  /// **'Version Info'**
  String get versionInfo;

  /// About page privacy policy item
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// About page user agreement item
  ///
  /// In en, this message translates to:
  /// **'User Agreement'**
  String get userAgreement;

  /// About page backup info item
  ///
  /// In en, this message translates to:
  /// **'Backup Info'**
  String get backupInfo;

  /// Chinese language option
  ///
  /// In en, this message translates to:
  /// **'Chinese'**
  String get chinese;

  /// English language option
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// All
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// CountDown Day
  ///
  /// In en, this message translates to:
  /// **'CountDown'**
  String get countdownDay;

  /// CountUp Day
  ///
  /// In en, this message translates to:
  /// **'CountUp'**
  String get countupDay;

  /// Calendar
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get calendar;

  /// Days Left
  ///
  /// In en, this message translates to:
  /// **'Days Left'**
  String get daysLeft;

  /// Days Ago
  ///
  /// In en, this message translates to:
  /// **'Days Ago'**
  String get daysAgo;

  /// Single day
  ///
  /// In en, this message translates to:
  /// **'day'**
  String get day;

  /// Multiple days
  ///
  /// In en, this message translates to:
  /// **'days'**
  String get days;

  /// Single day abbreviation
  ///
  /// In en, this message translates to:
  /// **'d'**
  String get dayShort;

  /// Timeline
  ///
  /// In en, this message translates to:
  /// **'Timeline'**
  String get timeline;

  /// Unpin
  ///
  /// In en, this message translates to:
  /// **'Unpin'**
  String get unpin;

  /// Pin
  ///
  /// In en, this message translates to:
  /// **'Pin'**
  String get pin;

  /// Add Special Day
  ///
  /// In en, this message translates to:
  /// **'Add Special Day'**
  String get addSpecialDay;

  /// Enter Title
  ///
  /// In en, this message translates to:
  /// **'Enter Title'**
  String get enterTitle;

  /// Target Date
  ///
  /// In en, this message translates to:
  /// **'Target Date'**
  String get targetDate;

  /// Background Settings
  ///
  /// In en, this message translates to:
  /// **'Background Settings'**
  String get backgroundSettings;

  /// Preview
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get preview;

  /// Single year
  ///
  /// In en, this message translates to:
  /// **'year'**
  String get year;

  /// Multiple years
  ///
  /// In en, this message translates to:
  /// **'years'**
  String get years;

  /// Single year abbreviation
  ///
  /// In en, this message translates to:
  /// **'yr'**
  String get yearShort;

  /// Multiple years abbreviation
  ///
  /// In en, this message translates to:
  /// **'yrs'**
  String get yearsShort;

  /// Single month
  ///
  /// In en, this message translates to:
  /// **'month'**
  String get month;

  /// Multiple months
  ///
  /// In en, this message translates to:
  /// **'months'**
  String get months;

  /// Single month abbreviation
  ///
  /// In en, this message translates to:
  /// **'mo'**
  String get monthShort;

  /// Multiple months abbreviation
  ///
  /// In en, this message translates to:
  /// **'mos'**
  String get monthsShort;

  /// Single week
  ///
  /// In en, this message translates to:
  /// **'week'**
  String get week;

  /// Multiple weeks
  ///
  /// In en, this message translates to:
  /// **'weeks'**
  String get weeks;

  /// Single week abbreviation
  ///
  /// In en, this message translates to:
  /// **'wk'**
  String get weekShort;

  /// Multiple weeks abbreviation
  ///
  /// In en, this message translates to:
  /// **'wks'**
  String get weeksShort;

  /// Edit
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// Delete
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// Save
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Cancel
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Confirm
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @eventPrefixToday.
  ///
  /// In en, this message translates to:
  /// **''**
  String get eventPrefixToday;

  /// No description provided for @eventPrefixTodayOrdinal.
  ///
  /// In en, this message translates to:
  /// **'The'**
  String get eventPrefixTodayOrdinal;

  /// No description provided for @eventPrefixFuture.
  ///
  /// In en, this message translates to:
  /// **'In'**
  String get eventPrefixFuture;

  /// No description provided for @eventPrefixPastOrdinal.
  ///
  /// In en, this message translates to:
  /// **'The'**
  String get eventPrefixPastOrdinal;

  /// No description provided for @eventPrefixPast.
  ///
  /// In en, this message translates to:
  /// **''**
  String get eventPrefixPast;

  /// No description provided for @ordinalSuffix1.
  ///
  /// In en, this message translates to:
  /// **'st'**
  String get ordinalSuffix1;

  /// No description provided for @ordinalSuffix2.
  ///
  /// In en, this message translates to:
  /// **'nd'**
  String get ordinalSuffix2;

  /// No description provided for @ordinalSuffix3.
  ///
  /// In en, this message translates to:
  /// **'rd'**
  String get ordinalSuffix3;

  /// No description provided for @ordinalSuffixOther.
  ///
  /// In en, this message translates to:
  /// **'th'**
  String get ordinalSuffixOther;

  /// No description provided for @eventToday.
  ///
  /// In en, this message translates to:
  /// **'today'**
  String get eventToday;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'zh': return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
