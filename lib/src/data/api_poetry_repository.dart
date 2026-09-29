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
  Future<List<Poem>> explore(ExploreQuery query) async {
    final search = query.search.trim();
    final poems = search.isEmpty
        ? (await _client.poems.list(
            filters: sdk.PoemFilters(style: _toSdkStyle(query.style)),
          )).items
        : (await _client.search.search(
            search,
            type: sdk.SearchType.poems,
          )).poems;
    return poems
        .where(
          (poem) =>
              query.style == null ||
              _fromSdkStyle(poem.poemStyle) == query.style,
        )
        .map(_fromSdkPoem)
        .toList(growable: false);
  }

  @override
  Future<Poet> poet(String id) async =>
      _fromSdkPoet(await _client.poets.get(_numericId(id)));

  @override
  Future<List<Poem>> poemsByPoet(String poetId) async =>
      (await _client.poets.poems(
        _numericId(poetId),
      )).items.map(_fromSdkPoem).toList(growable: false);

  int _numericId(String id) {
    final value = int.tryParse(id);
    if (value == null) {
      throw ArgumentError.value(id, 'id', 'Expected a numeric API id.');
    }
    return value;
  }

  Poem _fromSdkPoem(sdk.Poem poem) => Poem(
    id: poem.id.toString(),
    title: poem.title,
    poet: Poet(
      id: poem.poet.id.toString(),
      name: poem.poet.name,
      era: poem.era.name ?? '',
    ),
    style: _fromSdkStyle(poem.poemStyle),
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
