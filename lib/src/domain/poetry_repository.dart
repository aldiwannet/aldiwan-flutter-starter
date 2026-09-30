import 'models.dart';

abstract class PoetryRepository {
  Future<ResultPage<PoemSummary>> explore(ExploreQuery query, {int page = 1});
  Future<Poem> poem(String id);
  Future<Poet> poet(String id);
  Future<ResultPage<PoemSummary>> poemsByPoet(String poetId, {int page = 1});
}
