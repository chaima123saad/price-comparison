// lib/services/storage_service.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product_model.dart';

class StorageService {
  static const String _favoritesKey = 'favorites';
  static const String _recentSearchesKey = 'recent_searches';

  Future<void> addToFavorites(Product product) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = await getFavorites();
    favorites.add(product);
    
    final favoritesJson = favorites.map((p) {
      return {
        'id': p.id,
        'title': p.title,
        'imageUrl': p.imageUrl,
        'brand': p.brand,
      };
    }).toList();
    
    await prefs.setString(_favoritesKey, json.encode(favoritesJson));
  }

  Future<void> removeFromFavorites(String productId) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = await getFavorites();
    favorites.removeWhere((p) => p.id == productId);
    
    final favoritesJson = favorites.map((p) {
      return {
        'id': p.id,
        'title': p.title,
        'imageUrl': p.imageUrl,
        'brand': p.brand,
      };
    }).toList();
    
    await prefs.setString(_favoritesKey, json.encode(favoritesJson));
  }

  Future<List<Product>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favoritesJson = prefs.getString(_favoritesKey);
    
    if (favoritesJson == null) return [];
    
    try {
      final List<dynamic> data = json.decode(favoritesJson);
      return data.map((item) {
        return Product(
          id: item['id'],
          title: item['title'],
          imageUrl: item['imageUrl'],
          brand: item['brand'],
        );
      }).toList();
    } catch (e) {
      return [];
    }
  }

  Future<bool> isFavorite(String productId) async {
    final favorites = await getFavorites();
    return favorites.any((p) => p.id == productId);
  }

  Future<void> addRecentSearch(String query) async {
    if (query.trim().isEmpty) return;
    
    final prefs = await SharedPreferences.getInstance();
    final searches = await getRecentSearches();
    
    searches.removeWhere((s) => s.toLowerCase() == query.toLowerCase());
    searches.insert(0, query);
    
    if (searches.length > 10) {
      searches.removeLast();
    }
    
    await prefs.setStringList(_recentSearchesKey, searches);
  }

  Future<List<String>> getRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_recentSearchesKey) ?? [];
  }

  Future<void> clearRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_recentSearchesKey);
  }
}