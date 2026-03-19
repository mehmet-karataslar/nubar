// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'نوبار';

  @override
  String get login => 'تسجيل الدخول';

  @override
  String get register => 'التسجيل';

  @override
  String get email => 'البريد الإلكتروني';

  @override
  String get password => 'كلمة المرور';

  @override
  String get username => 'اسم المستخدم';

  @override
  String get fullName => 'الاسم الكامل';

  @override
  String get forgotPassword => 'نسيت كلمة المرور؟';

  @override
  String get dontHaveAccount => 'ليس لديك حساب؟';

  @override
  String get alreadyHaveAccount => 'لديك حساب بالفعل؟';

  @override
  String get createAccount => 'إنشاء حساب';

  @override
  String get logout => 'تسجيل الخروج';

  @override
  String get feed => 'الأخبار';

  @override
  String get search => 'بحث';

  @override
  String get create => 'إنشاء';

  @override
  String get notifications => 'الإشعارات';

  @override
  String get profile => 'الملف الشخصي';

  @override
  String get messages => 'الرسائل';

  @override
  String get settings => 'الإعدادات';

  @override
  String get editProfile => 'تعديل الملف الشخصي';

  @override
  String get followers => 'المتابعون';

  @override
  String get following => 'المتابَعون';

  @override
  String get posts => 'المنشورات';

  @override
  String get communities => 'المجتمعات';

  @override
  String get createPost => 'إنشاء منشور';

  @override
  String get createCommunity => 'إنشاء مجتمع';

  @override
  String get writePost => 'ماذا يدور في ذهنك؟';

  @override
  String get comment => 'تعليق';

  @override
  String get comments => 'التعليقات';

  @override
  String get like => 'إعجاب';

  @override
  String get share => 'مشاركة';

  @override
  String get repost => 'إعادة النشر';

  @override
  String get bookmark => 'حفظ';

  @override
  String get follow => 'متابعة';

  @override
  String get unfollow => 'إلغاء المتابعة';

  @override
  String get report => 'إبلاغ';

  @override
  String get delete => 'حذف';

  @override
  String get cancel => 'إلغاء';

  @override
  String get save => 'حفظ';

  @override
  String get send => 'إرسال';

  @override
  String get done => 'تم';

  @override
  String get loading => 'جاري التحميل...';

  @override
  String get error => 'خطأ';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get noResults => 'لا توجد نتائج';

  @override
  String get noPosts => 'لا توجد منشورات بعد';

  @override
  String get noNotifications => 'لا توجد إشعارات بعد';

  @override
  String get noMessages => 'لا توجد رسائل بعد';

  @override
  String get selectLanguage => 'اختر اللغة';

  @override
  String get selectTheme => 'اختر السمة';

  @override
  String get bio => 'السيرة الذاتية';

  @override
  String get website => 'الموقع الإلكتروني';

  @override
  String get location => 'الموقع';

  @override
  String joinedDate(String date) {
    return 'انضم في $date';
  }

  @override
  String followerCount(int count) {
    return '$count متابع';
  }

  @override
  String followingCount(int count) {
    return '$count متابَع';
  }

  @override
  String postCount(int count) {
    return '$count منشور';
  }

  @override
  String get welcomeTitle => 'مرحباً بك في نوبار';

  @override
  String get welcomeSubtitle => 'منصة رقمية للثقافة الكردية';

  @override
  String get onboardingTitle1 => 'شارك';

  @override
  String get onboardingDesc1 => 'شارك النصوص والصور والفيديو وملفات PDF';

  @override
  String get onboardingTitle2 => 'المجتمع';

  @override
  String get onboardingDesc2 => 'أنشئ مجتمعات وانضم إليها';

  @override
  String get onboardingTitle3 => 'تواصل';

  @override
  String get onboardingDesc3 => 'تواصل مع أكراد آخرين';

  @override
  String get getStarted => 'ابدأ';

  @override
  String get theme => 'السمة';

  @override
  String get language => 'اللغة';

  @override
  String get darkMode => 'الوضع الداكن';

  @override
  String get lightMode => 'الوضع الفاتح';

  @override
  String get themeNubar => 'نوبار';

  @override
  String get themeDark => 'داكن';

  @override
  String get themeLight => 'فاتح';

  @override
  String get themeEarth => 'أرضي';

  @override
  String get themeOcean => 'محيطي';

  @override
  String get themeAmoled => 'AMOLED';

  @override
  String get addImage => 'إضافة صورة';

  @override
  String get addVideo => 'إضافة فيديو';

  @override
  String get addPdf => 'إضافة PDF';

  @override
  String get post => 'نشر';

  @override
  String get writeComment => 'اكتب تعليقاً...';

  @override
  String memberCount(int count) {
    return '$count عضو';
  }

  @override
  String get joinCommunity => 'انضم';

  @override
  String get leaveCommunity => 'غادر';

  @override
  String get communitySettings => 'إعدادات المجتمع';

  @override
  String get trending => 'الرائج';

  @override
  String get forYou => 'لك';

  @override
  String get block => 'حظر';

  @override
  String get unblock => 'إلغاء الحظر';

  @override
  String get blocked => 'محظور';

  @override
  String get blockUser => 'حظر المستخدم';

  @override
  String get unblockUser => 'إلغاء حظر المستخدم';

  @override
  String get userBlocked => 'تم حظر المستخدم';

  @override
  String get userUnblocked => 'تم إلغاء حظر المستخدم';

  @override
  String get reportReason => 'سبب الإبلاغ';

  @override
  String get spam => 'رسائل مزعجة';

  @override
  String get harassment => 'تحرش';

  @override
  String get hateSpeech => 'خطاب كراهية';

  @override
  String get misinformation => 'معلومات مضللة';

  @override
  String get other => 'أخرى';

  @override
  String get reportSubmitted => 'تم إرسال الإبلاغ';

  @override
  String get reportDetails => 'التفاصيل (اختياري)';

  @override
  String get badges => 'الشارات';

  @override
  String get level => 'المستوى';

  @override
  String get noBadges => 'لا توجد شارات بعد';

  @override
  String get online => 'متصل';

  @override
  String get typing => 'يكتب...';

  @override
  String get delivered => 'تم التسليم';

  @override
  String get newMessage => 'رسالة جديدة';

  @override
  String get verified => 'موثق';
}
