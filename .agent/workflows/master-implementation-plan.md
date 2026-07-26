---
description: خطة تنفيذ شاملة لتطوير تطبيق Ana Muslim
---

# 🚀 خطة التنفيذ الشاملة - Ana Muslim App

## المرحلة 1️⃣: البنية التحتية والإعدادات الأساسية ✅ (أول أسبوع)

### 1.1 تحديث Dependencies + إضافة مكتبات جديدة
- [ ] تحديث `pubspec.yaml` بالمكتبات المطلوبة
- [ ] إضافة `flutter_native_splash` للـ Splash Screen
- [ ] إضافة `audioplayers` أو الاعتماد على `just_audio`
- [ ] إضافة `vibration` للتأثيرات الحسية
- [ ] التأكد من `permission_handler` محدث
- [ ] إضافة `cached_network_image` لتحسين الأداء

**الخطوات:**
```bash
flutter pub add flutter_native_splash
flutter pub add vibration
flutter pub add cached_network_image
flutter pub upgrade
flutter pub get
```

### 1.2 إعداد Android Configuration
- [ ] تحديث `minSdkVersion` إلى 21
- [ ] تحديث `targetSdkVersion` إلى 34
- [ ] تفعيل `multidex`
- [ ] إضافة ProGuard rules
- [ ] تحديث `AndroidManifest.xml` بكل الصلاحيات

**ملفات للتعديل:**
- `android/app/build.gradle.kts`
- `android/app/src/main/AndroidManifest.xml`
- `android/app/proguard-rules.pro`

### 1.3 إعداد الخطوط (Typography System)
- [ ] إضافة Google Fonts:
  - Cairo (عربي)
  - Poppins (إنجليزي)
  - Noto Sans (فرنسي)
- [ ] إنشاء `lib/utils/text_styles.dart` لتوحيد الأنماط
- [ ] تحديد line heights, font weights, sizes

---

## المرحلة 2️⃣: Splash Screen احترافية 🎨 (يوم واحد)

### 2.1 تصميم Splash Screen
- [ ] إنشاء صورة splash بتصميم إسلامي
- [ ] إضافة شعار التطبيق
- [ ] كتابة "بسم الله الرحمن الرحيم"
- [ ] دعم Light + Dark mode

### 2.2 تكوين flutter_native_splash
- [ ] إنشاء `flutter_native_splash.yaml`
- [ ] توليد splash screens
```bash
dart run flutter_native_splash:create
```

### 2.3 إضافة Animation
- [ ] إنشاء `lib/screens/splash_screen.dart`
- [ ] Fade-in animation
- [ ] Navigation تلقائي للشاشة الرئيسية بعد 2-3 ثواني

---

## المرحلة 3️⃣: الشاشة الرئيسية - Redesign 🏠 (يومين)

### 3.1 تصميم UI جديد
- [ ] إنشاء `lib/screens/home_screen.dart` جديد
- [ ] Grid layout للأيقونات الرئيسية:
  - القرآن الكريم
  - مواقيت الصلاة
  - الأذكار
  - الحديث
  - القبلة
  - التسبيح
  - الأسماء الحسنى

### 3.2 ثيم إسلامي راقي
- [ ] ألوان: Turquoise + Gold
- [ ] ظلال ناعمة (Soft shadows)
- [ ] Rounded corners
- [ ] Glassmorphism effects

### 3.3 Header للصلاة القادمة
- [ ] عرض الوقت الحالي
- [ ] عرض الصلاة القادمة
- [ ] Countdown timer

---

## المرحلة 4️⃣: نظام مواقيت الصلاة + GPS 🕌 (3 أيام)

### 4.1 طلب الصلاحيات
- [ ] إنشاء `lib/services/permission_service.dart`
- [ ] طلب إذن الموقع عند أول تشغيل
- [ ] Handle permission denied

### 4.2 GPS Service
- [ ] تحسين `lib/services/prayer_times_service.dart`
- [ ] استخدام Geolocator
- [ ] حساب المواقيت بـ Adhan package
- [ ] Geocoding للحصول على اسم المدينة

### 4.3 تحسين UI
- [ ] تحديث `prayer_times_screen.dart`
- [ ] عرض:
  - الوقت الحالي
  - الموقع الحالي
  - الصلاة التالية (مميزة)
  - قائمة جميع المواقيت
- [ ] زر تحديث الموقع
- [ ] Animation لانتقال الأوقات

### 4.4 الإشعارات
- [ ] تفعيل إشعارات للصلوات
- [ ] صوت الأذان (اختياري)
- [ ] تنبيه قبل الأذان بـ 10 دقائق

---

## المرحلة 5️⃣: نظام القرآن الكريم - تطوير شامل 📖 (أسبوع)

### 5.1 تحسين Surah List Screen
- [ ] تحديث `quran_screen.dart`
- [ ] تصميم أنيق للقائمة
- [ ] Thumbnails للسور
- [ ] Search محسّن

### 5.2 صفحة قراءة القرآن - Redesign كامل
- [ ] تحديث `surah_detail_screen.dart`
- [ ] خط كبير وواضح (Cairo)
- [ ] تباعد مناسب بين الآيات (line height)
- [ ] دعم 3 لغات:
  - عربي
  - English (Poppins)
  - Français (Noto Sans)

### 5.3 Audio System - إصلاح كامل
- [ ] إصلاح مشاكل الصوت في `audio_player_screen.dart`
- [ ] اختبار على Android 13+
- [ ] إضافة أيقونة سماعة واضحة بجانب كل آية
- [ ] تظليل الآية أثناء التشغيل (Highlight)

### 5.4 Bottom Audio Player
- [ ] إنشاء `lib/widgets/bottom_audio_player.dart`
- [ ] عرض mini player في bottom
- [ ] أزرار: Play/Pause, Next, Previous, Repeat
- [ ] Progress slider
- [ ] يظهر في جميع الشاشات

### 5.5 Quran Page Reader (مثل المصحف)
- [ ] إنشاء `lib/screens/quran_page_reader.dart`
- [ ] عرض الصفحات مثل المصحف الحقيقي
- [ ] Swipe بين الصفحات
- [ ] Bookmark system
- [ ] Last read position

---

## المرحلة 6️⃣: نظام الأذكار - تحسين شامل 📿 (3 أيام)

### 6.1 تصميم جديد
- [ ] تحديث `adhkar_screen.dart`
- [ ] تصنيفات:
  - أذكار الصباح
  - أذكار المساء
  - أذكار النوم
  - أذكار المسجد
  - أذكار متنوعة

### 6.2 Adhkar Card Design
- [ ] نص كبير وواضح
- [ ] عداد للتكرار
- [ ] زر نسخ
- [ ] زر مشاركة
- [ ] تأثير صوتي عند الضغط
- [ ] Haptic feedback (vibration)

### 6.3 Counter System
- [ ] حفظ العداد في SharedPreferences
- [ ] Reset button
- [ ] Progress indicator

---

## المرحلة 7️⃣: التسبيح (Tasbih) - تصميم احترافي 📿 (يومين)

### 7.1 إنشاء Tasbih Screen
- [ ] `lib/screens/tasbih_screen.dart`
- [ ] عداد كبير في المنتصف
- [ ] خلفية إسلامية راقية

### 7.2 Features
- [ ] Tap to increment
- [ ] Vibration على كل عدّ
- [ ] صوت تسبيح خفيف (اختياري)
- [ ] زر Reset
- [ ] حفظ العداد
- [ ] Multiple counters (تسبيح، تحميد، تكبير)

### 7.3 Theming
- [ ] ثيمات: Gold, Mint, Turquoise
- [ ] Gradient backgrounds
- [ ] Smooth animations

---

## المرحلة 8️⃣: القبلة (Qibla) - إصلاح + تحسين 🧭 (يومين)

### 8.1 إنشاء/تحديث Qibla Screen
- [ ] `lib/screens/qibla_screen.dart`
- [ ] استخدام `flutter_compass`
- [ ] حساب اتجاه القبلة بدقة

### 8.2 UI Design
- [ ] بوصلة دائرية احترافية
- [ ] تصميم مشابه لـ Islamic Compass
- [ ] Animation سلسة للدوران
- [ ] عرض درجة الاتجاه
- [ ] Vibration عند الاتجاه الصحيح

### 8.3 Fixes
- [ ] معالجة مشكلة الدوران
- [ ] دعم الأجهزة القديمة
- [ ] Sensor calibration

---

## المرحلة 9️⃣: الحديث - تحسينات (يوم واحد)

### 9.1 تحديث UI
- [ ] تحسين `hadith_screen.dart`
- [ ] عرض حديث اليوم
- [ ] شرح الحديث
- [ ] معلومات الراوي
- [ ] زر مشاركة

### 9.2 Daily Hadith
- [ ] 20+ حديث متجدد يومياً
- [ ] Notification للحديث اليومي

---

## المرحلة 🔟: Theme System + Settings (يومين)

### 10.1 Theme Provider
- [ ] إنشاء `lib/providers/theme_provider.dart`
- [ ] Light / Dark mode
- [ ] Custom color schemes

### 10.2 Settings Screen
- [ ] تحديث `settings_screen.dart`
- [ ] اختيار الثيم
- [ ] اختيار اللغة
- [ ] حجم الخط
- [ ] إعدادات الإشعارات
- [ ] About page

---

## المرحلة 1️⃣1️⃣: Testing + Optimization (3 أيام)

### 11.1 Testing
- [ ] اختبار على أجهزة مختلفة
- [ ] اختبار Android versions (API 21-34)
- [ ] اختبار الصلاحيات
- [ ] اختبار الصوت
- [ ] اختبار GPS

### 11.2 Performance Optimization
- [ ] تحسين حجم APK
- [ ] Code minification
- [ ] Image optimization
- [ ] Lazy loading

### 11.3 Bug Fixes
- [ ] إصلاح جميع الأخطاء
- [ ] تحسين UX
- [ ] Smooth animations

---

## المرحلة 1️⃣2️⃣: Build + Release (يوم واحد)

### 12.1 Build APK/AAB
```bash
flutter build apk --release
flutter build appbundle --release
```

### 12.2 Signing
- [ ] إنشاء keystore
- [ ] توقيع التطبيق

### 12.3 Testing Release Build
- [ ] اختبار APK النهائي
- [ ] التأكد من جميع الميزات

### 12.4 Play Store Preparation
- [ ] Screenshots
- [ ] App description
- [ ] Privacy policy
- [ ] App icon

---

## ⏱️ الجدول الزمني المقترح

| المرحلة | المدة | الأولوية |
|---------|-------|----------|
| 1 - البنية التحتية | أسبوع | 🔴 عالية |
| 2 - Splash Screen | يوم | 🟡 متوسطة |
| 3 - الشاشة الرئيسية | يومين | 🔴 عالية |
| 4 - مواقيت الصلاة + GPS | 3 أيام | 🔴 عالية |
| 5 - القرآن الكريم | أسبوع | 🔴 عالية جداً |
| 6 - الأذكار | 3 أيام | 🟡 متوسطة |
| 7 - التسبيح | يومين | 🟢 منخفضة |
| 8 - القبلة | يومين | 🟡 متوسطة |
| 9 - الحديث | يوم | 🟢 منخفضة |
| 10 - Theme + Settings | يومين | 🟡 متوسطة |
| 11 - Testing | 3 أيام | 🔴 عالية |
| 12 - Build + Release | يوم | 🔴 عالية |

**المجموع:** ~4 أسابيع

---

## 🎯 الأولويات الفورية (نبدأ بها الآن!)

1. ✅ **إصلاح مشكلة الصوت** (حُلّت!)
2. 🔄 **تحديث pubspec.yaml** بجميع المكتبات
3. 🔄 **إعداد Android configuration**
4. 🔄 **إنشاء Splash Screen**
5. 🔄 **تحسين نظام القرآن + Audio Player**
6. 🔄 **إضافة GPS + Prayer Times**

---

## 📝 ملاحظات مهمة

- كل مرحلة يجب أن تُختبر قبل الانتقال للتالية
- التركيز على UX/UI احترافي
- الكود يجب أن يكون clean ومنظم
- Follow Material 3 guidelines
- دعم RTL كامل
- Accessibility support

---

**آخر تحديث:** 2025-12-02
**الحالة:** قيد التنفيذ 🚀
