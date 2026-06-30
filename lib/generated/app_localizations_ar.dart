// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'قائمة المهام العائلية';

  @override
  String get selectLanguage => 'اختر اللغة';

  @override
  String get english => 'الإنجليزية';

  @override
  String get arabic => 'العربية';

  @override
  String get welcome => 'مرحباً';

  @override
  String get pickNickname => 'اختر لقباً للبدء';

  @override
  String get yourNickname => 'لقبك';

  @override
  String get createFamily => 'إنشاء عائلة';

  @override
  String get joinFamily => 'انضمام لعائلة';

  @override
  String get joinFamilyDialog => 'انضمام لعائلة';

  @override
  String get familyCode => 'رمز العائلة';

  @override
  String get familyCodeHint => 'مثال: FAM123';

  @override
  String get cancel => 'إلغاء';

  @override
  String get join => 'انضمام';

  @override
  String get somethingWentWrong => 'حدث خطأ ما';

  @override
  String toDo(int count) {
    return 'مهام ($count)';
  }

  @override
  String completed(int count) {
    return 'مكتملة ($count)';
  }

  @override
  String get addTask => 'إضافة مهمة';

  @override
  String get taskTitle => 'عنوان المهمة';

  @override
  String get descriptionOptional => 'الوصف (اختياري)';

  @override
  String get addTaskButton => 'إضافة مهمة';

  @override
  String createdBy(String user) {
    return 'تم إنشاؤها بواسطة: $user';
  }

  @override
  String doneDate(String date) {
    return 'تم: $date';
  }

  @override
  String createdDate(String date) {
    return 'تم الإنشاء: $date';
  }

  @override
  String get deleteTask => 'حذف المهمة';

  @override
  String deleteConfirm(String title) {
    return 'حذف \"$title\"?';
  }

  @override
  String get delete => 'حذف';

  @override
  String get noTasksYet => 'لا توجد مهام بعد';

  @override
  String get tapToAdd => 'اضغط على زر + لإضافة مهمتك الأولى';

  @override
  String errorPrefix(String message) {
    return 'خطأ: $message';
  }
}
