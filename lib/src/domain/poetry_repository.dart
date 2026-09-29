import 'models.dart';

abstract class PoetryRepository {
  Future<List<Poem>> explore(ExploreQuery query);
  Future<Poet> poet(String id);
  Future<List<Poem>> poemsByPoet(String poetId);
}
