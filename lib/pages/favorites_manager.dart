import 'package:flutter/material.dart';

class FavoritesManager extends ChangeNotifier {
  static final FavoritesManager _instance = FavoritesManager._internal();
  factory FavoritesManager() => _instance;
  FavoritesManager._internal();

  final Set<int> _favoriteBusinessIds = {};

  bool isFavorite(int businessId) {
    return _favoriteBusinessIds.contains(businessId);
  }

  void toggleFavorite(int businessId) {
    if (_favoriteBusinessIds.contains(businessId)) {
      _favoriteBusinessIds.remove(businessId);
    } else {
      _favoriteBusinessIds.add(businessId);
    }
    notifyListeners();
  }

  List<int> get favoriteIds => _favoriteBusinessIds.toList();
}