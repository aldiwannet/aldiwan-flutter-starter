import 'models.dart';

abstract class PoetryRepository {
  Future<List<PoemSummary>> explore(ExploreQuery query);
  Future<Poem> poem(String id);
  Future<Poet> poet(String id);
  Future<List<PoemSummary>> poemsByPoet(String poetId);
}
