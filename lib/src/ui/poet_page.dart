import 'package:flutter/material.dart';

import '../data/favorites_store.dart';
import '../domain/models.dart';
import '../domain/poetry_repository.dart';
import 'poem_reader_page.dart';

class PoetPage extends StatelessWidget {
  const PoetPage({
    super.key,
    required this.poetId,
    required this.repository,
    required this.favorites,
  });
  final String poetId;
  final PoetryRepository repository;
  final FavoritesStore favorites;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('الشاعر')),
    body: FutureBuilder<List<Object>>(
      future: Future.wait<Object>([
        repository.poet(poetId),
        repository.poemsByPoet(poetId),
      ]),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text('تعذّر تحميل بيانات الشاعر'));
        }
        final poet = snapshot.data![0] as Poet;
        final poems = snapshot.data![1] as List<PoemSummary>;
        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            CircleAvatar(
              radius: 38,
              child: Text(
                poet.name.substring(0, 1),
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              poet.name,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            Text(poet.era, textAlign: TextAlign.center),
            const SizedBox(height: 20),
            Text(poet.bio, style: const TextStyle(height: 1.7)),
            const SizedBox(height: 24),
            Text('القصائد', style: Theme.of(context).textTheme.titleLarge),
            ...poems.map(
              (poem) => ListTile(
                title: Text(poem.title),
                trailing: const Icon(Icons.chevron_left),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PoemReaderPage(
                      poemId: poem.id,
                      repository: repository,
                      favorites: favorites,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    ),
  );
}
