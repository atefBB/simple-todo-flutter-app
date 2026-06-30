// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Family Todo';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get english => 'English';

  @override
  String get arabic => 'العربية';

  @override
  String get welcome => 'Welcome';

  @override
  String get pickNickname => 'Pick a nickname to get started';

  @override
  String get yourNickname => 'Your nickname';

  @override
  String get createFamily => 'Create Family';

  @override
  String get joinFamily => 'Join Family';

  @override
  String get joinFamilyDialog => 'Join Family';

  @override
  String get familyCode => 'Family code';

  @override
  String get familyCodeHint => 'e.g. FAM123';

  @override
  String get cancel => 'Cancel';

  @override
  String get join => 'Join';

  @override
  String get somethingWentWrong => 'Something went wrong';

  @override
  String toDo(int count) {
    return 'To Do ($count)';
  }

  @override
  String completed(int count) {
    return 'Completed ($count)';
  }

  @override
  String get addTask => 'Add Task';

  @override
  String get taskTitle => 'Task title';

  @override
  String get descriptionOptional => 'Description (optional)';

  @override
  String get addTaskButton => 'Add Task';

  @override
  String createdBy(String user) {
    return 'Created by: $user';
  }

  @override
  String doneDate(String date) {
    return 'Done: $date';
  }

  @override
  String createdDate(String date) {
    return 'Created: $date';
  }

  @override
  String get deleteTask => 'Delete Task';

  @override
  String deleteConfirm(String title) {
    return 'Delete \"$title\"?';
  }

  @override
  String get delete => 'Delete';

  @override
  String get noTasksYet => 'No tasks yet';

  @override
  String get tapToAdd => 'Tap the + button to add your first task';

  @override
  String errorPrefix(String message) {
    return 'Error: $message';
  }
}
