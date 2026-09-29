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
  late Future<List<Poem>> _poems;
  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() => _poems = widget.repository.explore(
    ExploreQuery(search: _search, style: _style),
  );
  void _setStyle(PoemStyle? value) => setState(() {
    _style = value;
    _reload();
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
      onRefresh: () async => setState(_reload),
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
                    onSubmitted: (value) => setState(() {
                      _search = value;
                      _reload();
                    }),
                  ),
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        ChoiceChip(
                          label: const Text('الكل'),
                          selected: _style == null,
                          onSelected: (_) => _setStyle(null),
                        ),
                        const SizedBox(width: 8),
                        ...PoemStyle.values.map(
                          (style) => Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: ChoiceChip(
                              label: Text(styleName(style)),
                              selected: _style == style,
                              onSelected: (_) => _setStyle(style),
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
          FutureBuilder<List<Poem>>(
            future: _poems,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (snapshot.hasError) {
                return SliverFillRemaining(
                  child: MessageState(
                    icon: Icons.cloud_off,
                    title: 'تعذّر تحميل القصائد',
                    action: TextButton(
                      onPressed: () => setState(_reload),
                      child: const Text('إعادة المحاولة'),
                    ),
                  ),
                );
              }
              final allPoems = snapshot.data ?? const <Poem>[];
              final poems = _favoritesOnly
                  ? allPoems
                        .where((poem) => widget.favorites.contains(poem.id))
                        .toList()
                  : allPoems;
              if (poems.isEmpty) {
                return const SliverFillRemaining(
                  child: MessageState(
                    icon: Icons.search_off,
                    title: 'لا توجد نتائج',
                  ),
                );
              }
              return SliverList.builder(
                itemCount: poems.length,
                itemBuilder: (context, index) {
                  final poem = poems[index];
                  return PoemCard(
                    poem: poem,
                    favorites: widget.favorites,
                    onOpen: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PoemReaderPage(
                          poem: poem,
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
  final Poem poem;
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
