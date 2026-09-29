import '../domain/models.dart';
import '../domain/poetry_repository.dart';

class DemoPoetryRepository implements PoetryRepository {
  static const _mutanabbi = Poet(
    id: 'mutanabbi',
    name: 'المتنبي',
    era: 'العصر العباسي',
    bio: 'أحمد بن الحسين، أحد أشهر شعراء العربية وأكثرهم تأثيرًا.',
  );
  static const _shabbi = Poet(
    id: 'shabbi',
    name: 'أبو القاسم الشابي',
    era: 'العصر الحديث',
    bio: 'شاعر تونسي جمع في شعره بين الحس الرومانسي والنبرة الإنسانية.',
  );
  static const _sample = <Poem>[
    Poem(
      id: 'vertical-1',
      title: 'على قدر أهل العزم',
      poet: _mutanabbi,
      style: PoemStyle.vertical,
      meter: 'الطويل',
      lines: [
        'على قدر أهل العزم تأتي العزائم|وتأتي على قدر الكرام المكارم',
        'وتعظم في عين الصغير صغارها|وتصغر في عين العظيم العظائم',
      ],
    ),
    Poem(
      id: 'free-1',
      title: 'إرادة الحياة',
      poet: _shabbi,
      style: PoemStyle.freeVerse,
      lines: [
        'إذا الشعب يومًا أراد الحياة',
        'فلا بد أن يستجيب القدر',
        'ولا بد لليل أن ينجلي',
      ],
    ),
    Poem(
      id: 'prose-1',
      title: 'نافذة',
      poet: _shabbi,
      style: PoemStyle.prose,
      lines: [
        'نص تجريبي يوضّح أسلوب عرض قصيدة النثر.',
        'استبدله ببيانات المنصة عند ربط الـ SDK الرسمي.',
      ],
    ),
  ];

  @override
  Future<List<Poem>> explore(ExploreQuery query) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    final needle = query.search.trim();
    return _sample
        .where(
          (poem) =>
              (query.style == null || poem.style == query.style) &&
              (needle.isEmpty ||
                  poem.title.contains(needle) ||
                  poem.poet.name.contains(needle)),
        )
        .toList(growable: false);
  }

  @override
  Future<Poet> poet(String id) async =>
      _sample.firstWhere((poem) => poem.poet.id == id).poet;
  @override
  Future<List<Poem>> poemsByPoet(String poetId) async =>
      _sample.where((poem) => poem.poet.id == poetId).toList(growable: false);
}
