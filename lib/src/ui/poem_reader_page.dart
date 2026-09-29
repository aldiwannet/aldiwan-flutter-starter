import 'package:flutter/material.dart';

import '../data/favorites_store.dart';
import '../domain/models.dart';

class PoemReaderPage extends StatelessWidget {
  const PoemReaderPage({
    super.key,
    required this.poem,
    required this.favorites,
  });
  final Poem poem;
  final FavoritesStore favorites;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(poem.title),
      actions: [
        AnimatedBuilder(
          animation: favorites,
          builder: (_, child) => IconButton(
            onPressed: () => favorites.toggle(poem.id),
            icon: Icon(
              favorites.contains(poem.id)
                  ? Icons.favorite
                  : Icons.favorite_border,
            ),
          ),
        ),
      ],
    ),
    body: SelectionArea(
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
        children: [
          Text(
            poem.poet.name,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          if (poem.meter != null)
            Text('البحر: ${poem.meter}', textAlign: TextAlign.center),
          const SizedBox(height: 28),
          ...poem.lines.map(
            (line) => poem.style == PoemStyle.vertical
                ? Verse(line: line)
                : Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      line,
                      style: Theme.of(
                        context,
                      ).textTheme.titleLarge?.copyWith(height: 1.8),
                    ),
                  ),
          ),
        ],
      ),
    ),
  );
}

class Verse extends StatelessWidget {
  const Verse({super.key, required this.line});
  final String line;
  @override
  Widget build(BuildContext context) {
    final parts = line.split('|');
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: LayoutBuilder(
        builder: (_, constraints) {
          final style = Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(height: 1.8);
          if (constraints.maxWidth < 520 || parts.length < 2) {
            return Column(
              children: parts
                  .map(
                    (part) =>
                        Text(part, textAlign: TextAlign.center, style: style),
                  )
                  .toList(),
            );
          }
          return Row(
            children: parts
                .take(2)
                .map(
                  (part) => Expanded(
                    child: Text(
                      part,
                      textAlign: TextAlign.center,
                      style: style,
                    ),
                  ),
                )
                .toList(),
          );
        },
      ),
    );
  }
}
