import 'package:flutter/material.dart';

import '../data/favorites_store.dart';
import '../domain/models.dart';
import '../domain/poetry_repository.dart';
import 'poem_reader_page.dart';

class PoetPage extends StatefulWidget {
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
  State<PoetPage> createState() => _PoetPageState();
}

class _PoetPageState extends State<PoetPage> {
  late final Future<Poet> _poet;
  List<PoemSummary> _poems = const [];
  int _page = 0;
  int _lastPage = 1;
  bool _loading = false;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _poet = widget.repository.poet(widget.poetId);
    _loadMore();
  }

  Future<void> _loadMore() async {
    if (_loading || (_page > 0 && _page >= _lastPage)) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final result = await widget.repository.poemsByPoet(
        widget.poetId,
        page: _page + 1,
      );
      if (!mounted) return;
      setState(() {
        _poems = [..._poems, ...result.items];
        _page = result.currentPage;
        _lastPage = result.lastPage;
      });
    } catch (error) {
      if (mounted) setState(() => _error = error);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('الشاعر')),
    body: FutureBuilder<Poet>(
      future: _poet,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text('تعذّر تحميل بيانات الشاعر'));
        }
        final poet = snapshot.requireData;
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
            ..._poems.map(
              (poem) => ListTile(
                title: Text(poem.title),
                trailing: const Icon(Icons.chevron_left),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PoemReaderPage(
                      poemId: poem.id,
                      repository: widget.repository,
                      favorites: widget.favorites,
                    ),
                  ),
                ),
              ),
            ),
            if (_error != null)
              TextButton(
                onPressed: _loadMore,
                child: const Text('تعذّر تحميل المزيد — إعادة المحاولة'),
              )
            else if (_loading)
              const Padding(
                padding: EdgeInsets.all(20),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_page < _lastPage)
              Padding(
                padding: const EdgeInsets.all(12),
                child: FilledButton.icon(
                  onPressed: _loadMore,
                  icon: const Icon(Icons.expand_more),
                  label: const Text('تحميل المزيد'),
                ),
              ),
          ],
        );
      },
    ),
  );
}
