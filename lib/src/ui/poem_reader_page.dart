import 'package:flutter/material.dart';

import '../data/favorites_store.dart';
import '../domain/models.dart';
import '../domain/poetry_repository.dart';

class PoemReaderPage extends StatefulWidget {
  const PoemReaderPage({
    super.key,
    required this.poemId,
    required this.repository,
    required this.favorites,
  });

  final String poemId;
  final PoetryRepository repository;
  final FavoritesStore favorites;

  @override
  State<PoemReaderPage> createState() => _PoemReaderPageState();
}

class _PoemReaderPageState extends State<PoemReaderPage> {
  late Future<Poem> _poem;

  @override
  void initState() {
    super.initState();
    _poem = widget.repository.poem(widget.poemId);
  }

  void _retry() => setState(() {
    _poem = widget.repository.poem(widget.poemId);
  });

  @override
  Widget build(BuildContext context) => FutureBuilder<Poem>(
    future: _poem,
    builder: (context, snapshot) {
      final poem = snapshot.data;
      return Scaffold(
        appBar: AppBar(
          title: Text(poem?.title ?? 'القصيدة'),
          actions: [
            AnimatedBuilder(
              animation: widget.favorites,
              builder: (_, child) => IconButton(
                onPressed: () => widget.favorites.toggle(widget.poemId),
                icon: Icon(
                  widget.favorites.contains(widget.poemId)
                      ? Icons.favorite
                      : Icons.favorite_border,
                ),
              ),
            ),
          ],
        ),
        body: _body(context, snapshot),
      );
    },
  );

  Widget _body(BuildContext context, AsyncSnapshot<Poem> snapshot) {
    if (snapshot.connectionState != ConnectionState.done) {
      return const Center(child: CircularProgressIndicator());
    }
    if (snapshot.hasError || !snapshot.hasData) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.menu_book_outlined, size: 48),
            const SizedBox(height: 12),
            const Text('تعذّر تحميل النص الكامل للقصيدة'),
            const SizedBox(height: 8),
            TextButton(onPressed: _retry, child: const Text('إعادة المحاولة')),
          ],
        ),
      );
    }
    final poem = snapshot.requireData;
    return SelectionArea(
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
    );
  }
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
