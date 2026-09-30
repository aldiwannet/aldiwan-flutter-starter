import 'package:aldiwan/aldiwan.dart' as sdk;

import '../domain/models.dart';
import '../domain/poetry_repository.dart';

/// Domain adapter over the official Aldiwan SDK.
///
/// Accepting the client keeps construction, transport configuration, retries,
/// and test doubles outside the UI/domain layer.
class ApiPoetryRepository implements PoetryRepository {
  const ApiPoetryRepository(this._client);

  final sdk.AldiwanClient _client;

  @override
  Future<ResultPage<PoemSummary>> explore(
    ExploreQuery query, {
    int page = 1,
  }) async {
    final search = query.search.trim();
    if (search.isEmpty) {
      final result = await _client.poems.list(
        page: page,
        perPage: 20,
        filters: sdk.PoemFilters(style: _toSdkStyle(query.style)),
      );
      return ResultPage(
        items: result.items.map(_fromSdkPoemSummary).toList(growable: false),
        currentPage: result.currentPage,
        lastPage: result.lastPage,
      );
    }
    if (page > 1) {
      return const ResultPage(items: [], currentPage: 1, lastPage: 1);
    }
    final poems = (await _client.search.search(
      search,
      type: sdk.SearchType.poems,
      perPage: 20,
    )).poems;
    return ResultPage(
      items: poems
          .where(
            (poem) =>
                query.style == null ||
                _fromSdkStyle(poem.poemStyle) == query.style,
          )
          .map(_fromSdkPoemSummary)
          .toList(growable: false),
      currentPage: 1,
      lastPage: 1,
    );
  }

  @override
  Future<Poem> poem(String id) async =>
      _fromSdkPoem(await _client.poems.get(_numericId(id)));

  @override
  Future<Poet> poet(String id) async =>
      _fromSdkPoet(await _client.poets.get(_numericId(id)));

  @override
  Future<ResultPage<PoemSummary>> poemsByPoet(
    String poetId, {
    int page = 1,
  }) async {
    final result = await _client.poets.poems(
      _numericId(poetId),
      page: page,
      perPage: 20,
    );
    return ResultPage(
      items: result.items.map(_fromSdkPoemSummary).toList(growable: false),
      currentPage: result.currentPage,
      lastPage: result.lastPage,
    );
  }

  int _numericId(String id) {
    final value = int.tryParse(id);
    if (value == null) {
      throw ArgumentError.value(id, 'id', 'Expected a numeric API id.');
    }
    return value;
  }

  PoemSummary _fromSdkPoemSummary(sdk.PoemSummary poem) => PoemSummary(
    id: poem.id.toString(),
    title: poem.title,
    poet: Poet(
      id: poem.poet.id.toString(),
      name: poem.poet.name,
      era: poem.era.name ?? '',
    ),
    style: _fromSdkStyle(poem.poemStyle),
    excerpt: poem.excerpt,
    meter: poem.meter,
  );

  Poem _fromSdkPoem(sdk.Poem poem) => Poem(
    id: poem.id.toString(),
    title: poem.title,
    poet: Poet(
      id: poem.poet.id.toString(),
      name: poem.poet.name,
      era: poem.era.name ?? '',
    ),
    style: _fromSdkStyle(poem.poemStyle),
    excerpt: poem.excerpt,
    lines: poem.text
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList(growable: false),
    meter: poem.meter,
  );

  Poet _fromSdkPoet(sdk.Poet poet) => Poet(
    id: poet.id.toString(),
    name: poet.name,
    era: poet.era.name ?? '',
    bio: poet.biography ?? '',
  );

  sdk.PoemStyle? _toSdkStyle(PoemStyle? style) => switch (style) {
    PoemStyle.vertical => sdk.PoemStyle.vertical,
    PoemStyle.prose => sdk.PoemStyle.prose,
    PoemStyle.freeVerse => sdk.PoemStyle.freeVerse,
    null => null,
  };

  PoemStyle _fromSdkStyle(sdk.PoemStyle style) => switch (style) {
    sdk.PoemStyle.prose => PoemStyle.prose,
    sdk.PoemStyle.freeVerse => PoemStyle.freeVerse,
    sdk.PoemStyle.vertical || sdk.PoemStyle.unknown => PoemStyle.vertical,
  };
}
