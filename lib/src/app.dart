import 'package:flutter/material.dart';

import 'data/favorites_store.dart';
import 'domain/poetry_repository.dart';
import 'ui/explore_page.dart';

class AldiwanStarterApp extends StatefulWidget {
  const AldiwanStarterApp({
    super.key,
    required this.repository,
    required this.favorites,
  });
  final PoetryRepository repository;
  final FavoritesStore favorites;
  @override
  State<AldiwanStarterApp> createState() => _AldiwanStarterAppState();
}

class _AldiwanStarterAppState extends State<AldiwanStarterApp> {
  ThemeMode _themeMode = ThemeMode.system;
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'الديوان',
    locale: const Locale('ar'),
    builder: (context, child) =>
        Directionality(textDirection: TextDirection.rtl, child: child!),
    themeMode: _themeMode,
    theme: _theme(Brightness.light),
    darkTheme: _theme(Brightness.dark),
    home: ExplorePage(
      repository: widget.repository,
      favorites: widget.favorites,
      onThemeChanged: () => setState(
        () => _themeMode = _themeMode == ThemeMode.dark
            ? ThemeMode.light
            : ThemeMode.dark,
      ),
    ),
  );

  ThemeData _theme(Brightness brightness) => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF8A3B2D),
      brightness: brightness,
    ),
  );
}
