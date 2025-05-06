import 'package:flutter/material.dart';

mixin DsmesNavigationMixin {
  // Factory method to create unique keys
  static GlobalKey<NavigatorState> createNavigatorKey() {
    return GlobalKey<NavigatorState>(debugLabel: 'DSMESNavigator-${DateTime.now().millisecondsSinceEpoch}');
  }
  
  // Maintain active navigator key for backward compatibility
  static GlobalKey<NavigatorState>? _activeNavigatorKey;
  
  // Method to set the active navigator (called by parent page)
  static void setActiveNavigator(GlobalKey<NavigatorState> key) {
    _activeNavigatorKey = key;
  }
  
  // Method to get the navigation key safely for existing references
  static GlobalKey<NavigatorState> getNavigationKey() {
    if (_activeNavigatorKey == null) {
      throw Exception('No active DSMES navigator key set. The parent page should call DsmesNavigationMixin.setActiveNavigator first.');
    }
    return _activeNavigatorKey!;
  }
}