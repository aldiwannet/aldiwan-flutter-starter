import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoritesStore extends ChangeNotifier {
  FavoritesStore._(this._preferences, this._ids);
  static const _key = 'favorite_poem_ids';
  final SharedPreferences _preferences;
  final Set<String> _ids;

  static Future<FavoritesStore> load() async {
    final preferences = await SharedPreferences.getInstance();
    return FavoritesStore._(preferences, {
      ...preferences.getStringList(_key) ?? const [],
    });
  }

  bool contains(String id) => _ids.contains(id);
  Set<String> get ids => Set.unmodifiable(_ids);
  Future<void> toggle(String id) async {
    _ids.contains(id) ? _ids.remove(id) : _ids.add(id);
    notifyListeners();
    await _preferences.setStringList(_key, _ids.toList(growable: false));
  }
}
