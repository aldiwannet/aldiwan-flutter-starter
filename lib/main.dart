import 'package:flutter/material.dart';
import 'package:aldiwan/aldiwan.dart';

import 'src/app.dart';
import 'src/config/app_config.dart';
import 'src/data/api_poetry_repository.dart';
import 'src/data/demo_poetry_repository.dart';
import 'src/data/favorites_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final repository = AppConfig.demoMode
      ? DemoPoetryRepository()
      : ApiPoetryRepository(
          AldiwanClient(
            apiKey: AppConfig.apiKey,
            baseUri: Uri.parse(AppConfig.apiBaseUrl),
          ),
        );
  runApp(
    AldiwanStarterApp(
      repository: repository,
      favorites: await FavoritesStore.load(),
    ),
  );
}
