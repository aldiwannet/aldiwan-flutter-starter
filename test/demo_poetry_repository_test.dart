import 'package:aldiwan_flutter_starter/src/data/demo_poetry_repository.dart';
import 'package:aldiwan_flutter_starter/src/domain/models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('filters poems by style', () async {
    final poems = await DemoPoetryRepository().explore(
      const ExploreQuery(style: PoemStyle.vertical),
    );
    expect(poems.items, isNotEmpty);
    expect(
      poems.items.every((poem) => poem.style == PoemStyle.vertical),
      isTrue,
    );
  });

  test('searches by poet name', () async {
    final poems = await DemoPoetryRepository().explore(
      const ExploreQuery(search: 'المتنبي'),
    );
    expect(poems.items, hasLength(1));
  });
}
