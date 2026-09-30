enum PoemStyle { vertical, prose, freeVerse }

class Poet {
  const Poet({
    required this.id,
    required this.name,
    required this.era,
    this.bio = '',
  });
  final String id;
  final String name;
  final String era;
  final String bio;
}

class PoemSummary {
  const PoemSummary({
    required this.id,
    required this.title,
    required this.poet,
    required this.style,
    required this.excerpt,
    this.meter,
  });
  final String id;
  final String title;
  final Poet poet;
  final PoemStyle style;
  final String excerpt;
  final String? meter;
}

class Poem extends PoemSummary {
  const Poem({
    required super.id,
    required super.title,
    required super.poet,
    required super.style,
    required super.excerpt,
    required this.lines,
    super.meter,
  });

  final List<String> lines;
}

class ExploreQuery {
  const ExploreQuery({this.search = '', this.style});
  final String search;
  final PoemStyle? style;
}

class ResultPage<T> {
  const ResultPage({
    required this.items,
    required this.currentPage,
    required this.lastPage,
  });

  final List<T> items;
  final int currentPage;
  final int lastPage;
  bool get hasNextPage => currentPage < lastPage;
}
