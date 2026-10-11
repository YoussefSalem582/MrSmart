// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'MrSmart';

  @override
  String get welcomeTitle =>
      'تحكّم في غرفة واحدة، وتعلّم كيف يعمل المنزل الذكي.';

  @override
  String get welcomeBody =>
      'ابدأ بغرفة محاكاة — دون أجهزة أو حساب أو خادم. اربط Home Assistant الخاص بك عندما تكون جاهزًا.';

  @override
  String get tryDemo => 'جرّب العرض التجريبي';

  @override
  String get connectHomeAssistant => 'الاتصال بـ Home Assistant';

  @override
  String get settings => 'الإعدادات';

  @override
  String get roomTitle => 'غرفتي';

  @override
  String get modeDemo => 'تجريبي';

  @override
  String get modeHomeAssistant => 'Home Assistant';

  @override
  String get modeNone => 'غير مُعَدّ';

  @override
  String get simulatedBadge => 'محاكاة';

  @override
  String get simulatedNotice => 'بيانات محاكاة — ليست قراءات من أجهزة حقيقية.';

  @override
  String get connectionConnecting => 'جارٍ الاتصال…';

  @override
  String get connectionConnected => 'متصل';

  @override
  String connectionReconnecting(int seconds, int attempt) {
    return 'غير متصل — إعادة المحاولة خلال $seconds ث (المحاولة $attempt)';
  }

  @override
  String get connectionDisconnected => 'غير متصل — التحكم معطّل';

  @override
  String get connectionAuthFailed =>
      'رُفض رمز الوصول. أعد إعداد الاتصال من الإعدادات.';

  @override
  String get valueOn => 'يعمل';

  @override
  String get valueOff => 'مطفأ';

  @override
  String get valueUnknown => 'غير معروف';

  @override
  String get valueUnavailable => 'غير متاح';

  @override
  String get deviceRemoved => 'أُزيل من المصدر';

  @override
  String get deviceLoading => 'بانتظار الحالة الأولى…';

  @override
  String lastConfirmed(String time) {
    return 'آخر تأكيد $time';
  }

  @override
  String staleNote(String time) {
    return 'آخر قيمة معروفة · أُكّدت $time';
  }

  @override
  String get commandPendingOn => 'جارٍ التشغيل… بانتظار التأكيد';

  @override
  String get commandPendingOff => 'جارٍ الإطفاء… بانتظار التأكيد';

  @override
  String commandFailedOn(String reason) {
    return 'فشل التشغيل: $reason';
  }

  @override
  String commandFailedOff(String reason) {
    return 'فشل الإطفاء: $reason';
  }

  @override
  String get commandUnconfirmedTimeout =>
      'لم يتأكد: لم يُبلغ الجهاز عن الحالة الجديدة في الوقت المحدد.';

  @override
  String get commandUnconfirmedConnection =>
      'لم يتأكد: انقطع الاتصال قبل أن يرد الجهاز.';

  @override
  String get controlHintOffline => 'التحكم معطّل أثناء انقطاع الاتصال.';

  @override
  String get kindLight => 'إضاءة';

  @override
  String get kindSwitch => 'مفتاح';

  @override
  String get kindInputBoolean => 'مفتاح مساعد';

  @override
  String get kindTemperature => 'درجة الحرارة';

  @override
  String get leaveRoom => 'مغادرة الغرفة';

  @override
  String get leaveRoomExplain =>
      'يطفئ أجهزة هذه الغرفة المختارة فقط. يجب أن يكون التطبيق مفتوحًا لتنفيذه. أي شيء يجب أن يحدث تلقائيًا — بجدول زمني أو عند تفعيل مستشعر — مكانه أتمتة في Home Assistant.';

  @override
  String get leaveRoomConfirm => 'إطفاء أجهزة الغرفة';

  @override
  String get leaveRoomRunning => 'جارٍ الإطفاء وانتظار التأكيد…';

  @override
  String get leaveRoomAllOff => 'تأكد إطفاء كل الأجهزة المختارة.';

  @override
  String get leaveRoomPartial => 'لم يُطفأ كل شيء. راجع كل جهاز أدناه.';

  @override
  String get leaveRoomNotConnected => 'أنت غير متصل، لذلك لم يُرسل أي شيء.';

  @override
  String get leaveRoomNothing => 'لا توجد أجهزة قابلة للتحكم في هذه الغرفة.';

  @override
  String get leaveOutcomeConfirmed => 'مطفأ (مؤكد)';

  @override
  String get leaveOutcomeAlreadyOff => 'مطفأ مسبقًا';

  @override
  String get leaveOutcomeFailed => 'فشل';

  @override
  String get leaveOutcomeUnconfirmed => 'لم يتأكد';

  @override
  String get leaveOutcomeSkipped => 'تم تخطيه';

  @override
  String get close => 'إغلاق';

  @override
  String get cancel => 'إلغاء';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get activityTitle => 'النشاط الأخير';

  @override
  String get activityEmpty => 'لا شيء بعد.';

  @override
  String activityCommandSentOn(String device) {
    return '$device: طُلب التشغيل';
  }

  @override
  String activityCommandSentOff(String device) {
    return '$device: طُلب الإطفاء';
  }

  @override
  String activityConfirmed(String device, String value) {
    return '$device: تأكد $value';
  }

  @override
  String activityFailed(String device) {
    return '$device: فشل الأمر';
  }

  @override
  String activityUnconfirmed(String device) {
    return '$device: لم يتأكد';
  }

  @override
  String activityExternal(String device, String value) {
    return '$device تغيّر إلى $value من خارج التطبيق';
  }

  @override
  String activityReading(String device, String value) {
    return '$device: قراءة جديدة $value';
  }

  @override
  String activityUnavailable(String device) {
    return '$device أصبح غير متاح';
  }

  @override
  String activityRemoved(String device) {
    return '$device أُزيل';
  }

  @override
  String get activityConnectionLost => 'انقطع الاتصال';

  @override
  String get activityReconnected => 'عاد الاتصال — حُدّثت الحالات';

  @override
  String get demoControlsTitle => 'أدوات العرض التجريبي';

  @override
  String get demoControlsHint =>
      'هذه الأدوات تحاكي أحداثًا واقعية لترى كيف يتفاعل التطبيق. لا شيء هنا يتحكم بجهاز حقيقي.';

  @override
  String get demoGoOffline => 'قطع الاتصال';

  @override
  String get demoGoOnline => 'إعادة الاتصال';

  @override
  String get demoFailNext => 'أفشل الأمر التالي';

  @override
  String get demoDropNext => 'أسقط التأكيد التالي';

  @override
  String get demoArmed => 'مُفعّل';

  @override
  String demoFlip(String device) {
    return 'بدّل $device من الخارج';
  }

  @override
  String demoMakeUnavailable(String device) {
    return 'اجعل $device غير متاح';
  }

  @override
  String demoMakeAvailable(String device) {
    return 'اجعل $device متاحًا';
  }

  @override
  String get demoNudgeTemperature => 'قراءة حرارة جديدة';

  @override
  String get failureNetwork =>
      'تعذّر الوصول إلى الخادم. تحقق من العنوان ومن أن الهاتف على نفس الشبكة.';

  @override
  String get failureTimeout => 'استغرق الخادم وقتًا طويلًا للرد.';

  @override
  String get failureTls => 'فشل الاتصال الآمن: الشهادة غير موثوقة.';

  @override
  String get failureAuth => 'رُفض رمز الوصول. تأكد أنه كامل وغير ملغى.';

  @override
  String get failurePermission => 'هذا الحساب غير مسموح له بذلك.';

  @override
  String get failureNotFound => 'غير موجود في المصدر.';

  @override
  String get failureInvalidUrl =>
      'أدخل عنوانًا صالحًا، مثل http://homeassistant.local:8123';

  @override
  String get failureInsecureUrl =>
      'هذا الإصدار يقبل عناوين https:// فقط. يُسمح بـ HTTP في إصدارات التطوير للتعلّم المحلي فقط.';

  @override
  String get failureNotConnected => 'غير متصل.';

  @override
  String get failureServer => 'أرجع Home Assistant خطأ.';

  @override
  String get failureSimulated => 'فشل محاكى (أداة تجريبية)';

  @override
  String get settingsLanguage => 'اللغة';

  @override
  String get settingsTheme => 'المظهر';

  @override
  String get themeSystem => 'النظام';

  @override
  String get themeLight => 'فاتح';

  @override
  String get themeDark => 'داكن';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageArabic => 'العربية';

  @override
  String get settingsMode => 'الوضع';

  @override
  String currentMode(String mode) {
    return 'الحالي: $mode';
  }

  @override
  String get switchToDemo => 'التبديل إلى التجريبي';

  @override
  String get chooseDevices => 'اختيار أجهزة الغرفة';

  @override
  String get reconfigureConnection => 'إعادة إعداد الاتصال';

  @override
  String get leaveMode => 'العودة للبداية';

  @override
  String get disconnectErase => 'قطع الاتصال ومسح بيانات الدخول';

  @override
  String get disconnectEraseBody =>
      'سيُحذف العنوان ورمز الوصول واختيار الغرفة من هذا الجهاز. ألغِ الرمز أيضًا من Home Assistant إن لم تعد تحتاجه.';

  @override
  String get erase => 'مسح';

  @override
  String get credentialsErased => 'تم مسح بيانات الدخول.';

  @override
  String get connectTitle => 'الاتصال بـ Home Assistant';

  @override
  String get connectIntro =>
      'يتصل MrSmart مباشرة بـ Home Assistant على شبكتك المحلية. لا يوجد خادم لـ MrSmart.';

  @override
  String get haUrlLabel => 'عنوان Home Assistant';

  @override
  String get haUrlHint => 'http://homeassistant.local:8123';

  @override
  String get haTokenLabel => 'رمز وصول طويل الأمد';

  @override
  String get haTokenHelp =>
      'أنشئه في Home Assistant: ملفك الشخصي ← الأمان ← رموز الوصول طويلة الأمد. يستطيع فعل كل ما يستطيعه حسابك، لذا يُفضّل مستخدم اختبار مخصص.';

  @override
  String get haTokenRequired => 'الصق رمز الوصول.';

  @override
  String get showToken => 'إظهار الرمز';

  @override
  String get hideToken => 'إخفاء الرمز';

  @override
  String get insecureHttpWarning =>
      'HTTP غير مشفّر: يمكن لأي شخص على الشبكة قراءة الرمز. استخدمه فقط على شبكتك المنزلية للتعلّم — وليس عبر الإنترنت أبدًا.';

  @override
  String get testAndSave => 'اختبار وحفظ';

  @override
  String get testing => 'جارٍ اختبار الاتصال…';

  @override
  String connectedTo(String name, String version) {
    return 'متصل بـ $name (Home Assistant $version)';
  }

  @override
  String get selectTitle => 'اختيار أجهزة الغرفة';

  @override
  String get selectSafety =>
      'اختر مصباحًا أو حِملًا مشابهًا غير حرج. لا تستخدم مفاتيح تشغّل سخانات أو مضخات أو معدات طبية أو أمنية أو أي معدات حرجة للسلامة مع هذا التطبيق التعليمي.';

  @override
  String get selectHint =>
      'تُعرض وتُدار فقط العناصر التي تختارها. لا يُمس أي شيء آخر في منزلك.';

  @override
  String selectSave(int count) {
    return 'استخدم $count مختارة';
  }

  @override
  String get selectEmpty =>
      'لم يُعثر على عناصر مدعومة. المدعوم: الإضاءة والمفاتيح ومفاتيح المساعد ومستشعرات الحرارة.';

  @override
  String get errorTitle => 'حدث خطأ';
}
