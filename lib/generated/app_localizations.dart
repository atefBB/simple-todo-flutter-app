import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

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
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Family Todo'**
  String get appTitle;

  /// Title on language selection screen
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// English language option
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// Arabic language option
  ///
  /// In en, this message translates to:
  /// **'العربية'**
  String get arabic;

  /// Welcome heading on setup screen
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcome;

  /// Subtitle prompting user to enter a nickname
  ///
  /// In en, this message translates to:
  /// **'Pick a nickname to get started'**
  String get pickNickname;

  /// Label for nickname text field
  ///
  /// In en, this message translates to:
  /// **'Your nickname'**
  String get yourNickname;

  /// Button to create a new family
  ///
  /// In en, this message translates to:
  /// **'Create Family'**
  String get createFamily;

  /// Button to join an existing family
  ///
  /// In en, this message translates to:
  /// **'Join Family'**
  String get joinFamily;

  /// Title of the join family dialog
  ///
  /// In en, this message translates to:
  /// **'Join Family'**
  String get joinFamilyDialog;

  /// Label for family code text field
  ///
  /// In en, this message translates to:
  /// **'Family code'**
  String get familyCode;

  /// Hint text for family code input
  ///
  /// In en, this message translates to:
  /// **'e.g. FAM123'**
  String get familyCodeHint;

  /// Cancel button label
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Join button label
  ///
  /// In en, this message translates to:
  /// **'Join'**
  String get join;

  /// Error message heading
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get somethingWentWrong;

  /// Section header for pending tasks
  ///
  /// In en, this message translates to:
  /// **'To Do ({count})'**
  String toDo(int count);

  /// Section header for completed tasks
  ///
  /// In en, this message translates to:
  /// **'Completed ({count})'**
  String completed(int count);

  /// App bar title on add task screen
  ///
  /// In en, this message translates to:
  /// **'Add Task'**
  String get addTask;

  /// Label for task title text field
  ///
  /// In en, this message translates to:
  /// **'Task title'**
  String get taskTitle;

  /// Label for description text field
  ///
  /// In en, this message translates to:
  /// **'Description (optional)'**
  String get descriptionOptional;

  /// Button to add a task
  ///
  /// In en, this message translates to:
  /// **'Add Task'**
  String get addTaskButton;

  /// Shows who created the task
  ///
  /// In en, this message translates to:
  /// **'Created by: {user}'**
  String createdBy(String user);

  /// Shows when task was completed
  ///
  /// In en, this message translates to:
  /// **'Done: {date}'**
  String doneDate(String date);

  /// Shows when task was created
  ///
  /// In en, this message translates to:
  /// **'Created: {date}'**
  String createdDate(String date);

  /// Shows due date of a task
  ///
  /// In en, this message translates to:
  /// **'Due: {date}'**
  String dueDate(String date);

  /// Hint text shown when no due date is set
  ///
  /// In en, this message translates to:
  /// **'Set a due date (optional)'**
  String get dueDateHint;

  /// Title of delete confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Delete Task'**
  String get deleteTask;

  /// Delete confirmation message
  ///
  /// In en, this message translates to:
  /// **'Delete \"{title}\"?'**
  String deleteConfirm(String title);

  /// Delete button label
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// Empty state title
  ///
  /// In en, this message translates to:
  /// **'No tasks yet'**
  String get noTasksYet;

  /// Empty state subtitle
  ///
  /// In en, this message translates to:
  /// **'Tap the + button to add your first task'**
  String get tapToAdd;

  /// Error message prefix
  ///
  /// In en, this message translates to:
  /// **'Error: {message}'**
  String errorPrefix(String message);
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
      <String>['ar', 'en'].contains(locale.languageCode);

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
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
