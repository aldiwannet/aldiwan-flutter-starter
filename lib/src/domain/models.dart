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

class Poem {
  const Poem({
    required this.id,
    required this.title,
    required this.poet,
    required this.style,
    required this.lines,
    this.meter,
  });
  final String id;
  final String title;
  final Poet poet;
  final PoemStyle style;
  final List<String> lines;
  final String? meter;
}

class ExploreQuery {
  const ExploreQuery({this.search = '', this.style});
  final String search;
  final PoemStyle? style;
}
