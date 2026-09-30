import 'package:flutter/material.dart';

import '../data/favorites_store.dart';
import '../domain/models.dart';
import '../domain/poetry_repository.dart';
import 'poem_reader_page.dart';
import 'poet_page.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({
    super.key,
    required this.repository,
    required this.favorites,
    required this.onThemeChanged,
  });
  final PoetryRepository repository;
  final FavoritesStore favorites;
  final VoidCallback onThemeChanged;
  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  PoemStyle? _style;
  String _search = '';
  bool _favoritesOnly = false;
  List<PoemSummary> _poems = const [];
  int _page = 0;
  int _lastPage = 1;
  bool _loading = false;
  Object? _error;
  int _generation = 0;
  @override
  void initState() {
    super.initState();
    _load(reset: true);
  }

  Future<void> _load({required bool reset}) async {
    if (_loading && !reset) return;
    final generation = reset ? ++_generation : _generation;
    setState(() {
      _loading = true;
      _error = null;
      if (reset) {
        _poems = const [];
        _page = 0;
        _lastPage = 1;
      }
    });
    try {
      final result = await widget.repository.explore(
        ExploreQuery(search: _search, style: _style),
        page: reset ? 1 : _page + 1,
      );
      if (!mounted || generation != _generation) return;
      setState(() {
        _poems = reset ? result.items : [..._poems, ...result.items];
        _page = result.currentPage;
        _lastPage = result.lastPage;
      });
    } catch (error) {
      if (mounted && generation == _generation) {
        setState(() => _error = error);
      }
    } finally {
      if (mounted && generation == _generation) {
        setState(() => _loading = false);
      }
    }
  }

  void _setStyle(PoemStyle? value) => setState(() {
    _style = value;
  });

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(_favoritesOnly ? 'المفضلة' : 'استكشف الديوان'),
      actions: [
        IconButton(
          tooltip: 'المفضلة',
          onPressed: () => setState(() => _favoritesOnly = !_favoritesOnly),
          icon: Icon(
            _favoritesOnly ? Icons.explore_outlined : Icons.favorite_outline,
          ),
        ),
        IconButton(
          tooltip: 'تغيير المظهر',
          onPressed: widget.onThemeChanged,
          icon: const Icon(Icons.brightness_6_outlined),
        ),
      ],
    ),
    body: RefreshIndicator(
      onRefresh: () => _load(reset: true),
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Column(
                children: [
                  SearchBar(
                    hintText: 'ابحث عن قصيدة أو شاعر',
                    leading: const Icon(Icons.search),
                    onSubmitted: (value) {
                      setState(() => _search = value);
                      _load(reset: true);
                    },
                  ),
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        ChoiceChip(
                          label: const Text('الكل'),
                          selected: _style == null,
                          onSelected: (_) {
                            _setStyle(null);
                            _load(reset: true);
                          },
                        ),
                        const SizedBox(width: 8),
                        ...PoemStyle.values.map(
                          (style) => Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: ChoiceChip(
                              label: Text(styleName(style)),
                              selected: _style == style,
                              onSelected: (_) {
                                _setStyle(style);
                                _load(reset: true);
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Builder(
            builder: (context) {
              if (_loading && _poems.isEmpty) {
                return const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (_error != null && _poems.isEmpty) {
                return SliverFillRemaining(
                  child: MessageState(
                    icon: Icons.cloud_off,
                    title: 'تعذّر تحميل القصائد',
                    action: TextButton(
                      onPressed: () => _load(reset: true),
                      child: const Text('إعادة المحاولة'),
                    ),
                  ),
                );
              }
              final poems = _favoritesOnly
                  ? _poems
                        .where((poem) => widget.favorites.contains(poem.id))
                        .toList()
                  : _poems;
              if (poems.isEmpty) {
                return const SliverFillRemaining(
                  child: MessageState(
                    icon: Icons.search_off,
                    title: 'لا توجد نتائج',
                  ),
                );
              }
              return SliverList.builder(
                itemCount: poems.length + (_page < _lastPage ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == poems.length) {
                    return Padding(
                      padding: const EdgeInsets.all(24),
                      child: Center(
                        child: FilledButton.icon(
                          onPressed: _loading
                              ? null
                              : () => _load(reset: false),
                          icon: _loading
                              ? const SizedBox.square(
                                  dimension: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.expand_more),
                          label: const Text('تحميل المزيد'),
                        ),
                      ),
                    );
                  }
                  final poem = poems[index];
                  return PoemCard(
                    poem: poem,
                    favorites: widget.favorites,
                    onOpen: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PoemReaderPage(
                          poemId: poem.id,
                          repository: widget.repository,
                          favorites: widget.favorites,
                        ),
                      ),
                    ),
                    onPoet: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PoetPage(
                          poetId: poem.poet.id,
                          repository: widget.repository,
                          favorites: widget.favorites,
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    ),
  );
}

class PoemCard extends StatelessWidget {
  const PoemCard({
    super.key,
    required this.poem,
    required this.favorites,
    required this.onOpen,
    required this.onPoet,
  });
  final PoemSummary poem;
  final FavoritesStore favorites;
  final VoidCallback onOpen;
  final VoidCallback onPoet;
  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.fromLTRB(16, 4, 16, 12),
    child: ListTile(
      contentPadding: const EdgeInsets.all(16),
      title: Text(poem.title, style: Theme.of(context).textTheme.titleLarge),
      subtitle: InkWell(
        onTap: onPoet,
        child: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text('${poem.poet.name} · ${styleName(poem.style)}'),
        ),
      ),
      trailing: AnimatedBuilder(
        animation: favorites,
        builder: (_, child) => IconButton(
          tooltip: favorites.contains(poem.id)
              ? 'إزالة من المفضلة'
              : 'إضافة إلى المفضلة',
          onPressed: () => favorites.toggle(poem.id),
          icon: Icon(
            favorites.contains(poem.id)
                ? Icons.favorite
                : Icons.favorite_border,
          ),
        ),
      ),
      onTap: onOpen,
    ),
  );
}

class MessageState extends StatelessWidget {
  const MessageState({
    super.key,
    required this.icon,
    required this.title,
    this.action,
  });
  final IconData icon;
  final String title;
  final Widget? action;
  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 48),
        const SizedBox(height: 12),
        Text(title),
        ...?action == null ? null : [action!],
      ],
    ),
  );
}

String styleName(PoemStyle style) => switch (style) {
  PoemStyle.vertical => 'عمودي',
  PoemStyle.prose => 'نثر',
  PoemStyle.freeVerse => 'تفعيلة',
};
