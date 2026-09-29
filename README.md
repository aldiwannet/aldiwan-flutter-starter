# Aldiwan Flutter Starter · قالب الديوان لـ Flutter

تطبيق مرجعي عربي، RTL-first، لبناء تجارب شعرية باستخدام منصة الديوان. يعمل فورًا ببيانات تجريبية ولا يحتوي على أي سر أو مفتاح API.

An Arabic, RTL-first reference app for building poetry experiences with Aldiwan. It runs immediately with demo data and contains no API secrets.

## المزايا

- استكشاف وبحث وفلاتر حسب نوع القصيدة.
- قارئ متجاوب للعمودي والنثر والتفعيلة.
- صفحة شاعر وقائمة قصائده.
- مفضلة محلية عبر `shared_preferences`.
- RTL وMaterial 3 ومظهر فاتح/داكن.
- حالات loading/error/empty وإعادة المحاولة.
- طبقة `PoetryRepository` مستقلة عن مصدر البيانات.
- CI للتنسيق والتحليل والاختبارات.

## التشغيل السريع · Quick start

```bash
flutter pub get
flutter run
```

الوضع الافتراضي يتصل بالعقد الرسمي ويتطلب مفتاح Bearer. مرّر المفتاح محليًا (ولا تلتزم به في Git):

```bash
flutter run \
  --dart-define=ALDIWAN_API_KEY=YOUR_KEY \
  --dart-define=ALDIWAN_API_BASE_URL=https://api.aldiwan.net/api/v1
```

للمعاينة دون شبكة استخدم صراحةً `--dart-define=ALDIWAN_DEMO_MODE=true`. لا يحدث fallback تلقائي يخفي أخطاء المصادقة أو الشبكة.

> `--dart-define` ليس مخزن أسرار؛ القيم قابلة للاستخراج من binaries. يصلح للتطوير بمفتاح محدود فقط. في الإنتاج، مرّر طلبات المصادقة عبر backend موثوق ولا تضمّن مفتاحًا مميزًا داخل التطبيق.

## ربط Aldiwan SDK · SDK integration

يستخدم التطبيق حزمة `aldiwan` الرسمية مباشرةً من إصدار Git ثابت:

```yaml
dependencies:
  aldiwan:
    git:
      url: https://github.com/aldiwannet/aldiwan-flutter.git
      ref: v0.1.0
```

يحوّل `ApiPoetryRepository` نماذج الـSDK إلى نماذج الواجهة خلف `PoetryRepository`، لذلك يمكن لاحقًا الانتقال إلى إصدار `pub.dev` دون تعديل الشاشات.

See [`docs/SDK_INTEGRATION.md`](docs/SDK_INTEGRATION.md) for the integration details.

## Structure

```text
lib/src/
├── config/       # public compile-time configuration
├── data/         # demo adapter and local favorites
├── domain/       # models and repository contract
└── ui/           # explore, reader, and poet screens
```

## الجودة · Quality

```bash
dart format lib test
flutter analyze
flutter test
```

The starter does not use or expose Aldiwan's private recitation endpoint.

## License

[MIT](LICENSE) © Aldiwan
