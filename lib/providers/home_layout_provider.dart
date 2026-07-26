import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

enum HomeWidgetType {
  header,
  nextPrayer,
  quickActions,
  dailyVerse, // Future placeholder
  hijriDate, // Future placeholder
}

class HomeWidgetItem {
  final HomeWidgetType type;
  bool isVisible;
  int order;

  HomeWidgetItem({
    required this.type,
    this.isVisible = true,
    required this.order,
  });

  Map<String, dynamic> toJson() => {
    'type': type.toString(),
    'isVisible': isVisible,
    'order': order,
  };

  factory HomeWidgetItem.fromJson(Map<String, dynamic> json) {
    return HomeWidgetItem(
      type: HomeWidgetType.values.firstWhere(
        (e) => e.toString() == json['type'],
        orElse: () => HomeWidgetType.header,
      ),
      isVisible: json['isVisible'] ?? true,
      order: json['order'] ?? 0,
    );
  }
}

class HomeLayoutProvider with ChangeNotifier {
  List<HomeWidgetItem> _layout = [
    HomeWidgetItem(type: HomeWidgetType.header, order: 0),
    HomeWidgetItem(type: HomeWidgetType.nextPrayer, order: 1),
    HomeWidgetItem(type: HomeWidgetType.quickActions, order: 2),
    HomeWidgetItem(type: HomeWidgetType.dailyVerse, order: 3),
    HomeWidgetItem(type: HomeWidgetType.hijriDate, order: 4),
  ];
  bool _isLoading = false;

  HomeLayoutProvider() {
    _loadLayout();
  }

  List<HomeWidgetItem> get activeWidgets {
    if (_layout.isEmpty) {
      _resetToDefault();
    }
    final active = _layout.where((item) => item.isVisible).toList();
    if (active.isEmpty) {
      _resetToDefault();
      return List<HomeWidgetItem>.from(_layout);
    }
    active.sort((a, b) => a.order.compareTo(b.order));
    return active;
  }

  List<HomeWidgetItem> get allWidgets {
    final all = List<HomeWidgetItem>.from(_layout);
    all.sort((a, b) => a.order.compareTo(b.order));
    return all;
  }

  bool get isLoading => _isLoading;

  Future<void> _loadLayout() async {
    final prefs = await SharedPreferences.getInstance();
    final String? savedLayout = prefs.getString('home_layout');

    if (savedLayout != null) {
      try {
        final List<dynamic> decoded = json.decode(savedLayout);
        _layout = decoded.map((item) => HomeWidgetItem.fromJson(item)).toList();

        // Check for missing new widget types and add them
        _ensureAllTypesExist();
      } catch (e) {
        debugPrint('Error loading layout: $e');
        _resetToDefault();
      }
    } else {
      _resetToDefault();
    }

    _isLoading = false;
    notifyListeners();
  }

  void _ensureAllTypesExist() {
    bool changed = false;
    for (var type in HomeWidgetType.values) {
      if (!_layout.any((item) => item.type == type)) {
        _layout.add(
          HomeWidgetItem(
            type: type,
            order: _layout.length,
            isVisible: true, // Enable all new widgets by default
          ),
        );
        changed = true;
      }
    }
    if (changed) _saveLayout();
  }

  void _resetToDefault() {
    _layout = [
      HomeWidgetItem(type: HomeWidgetType.header, order: 0),
      HomeWidgetItem(type: HomeWidgetType.nextPrayer, order: 1),
      HomeWidgetItem(type: HomeWidgetType.quickActions, order: 2),
      HomeWidgetItem(type: HomeWidgetType.hijriDate, order: 3, isVisible: true),
      HomeWidgetItem(
        type: HomeWidgetType.dailyVerse,
        order: 4,
        isVisible: true,
      ),
    ];
    _saveLayout();
  }

  Future<void> toggleVisibility(HomeWidgetType type) async {
    final index = _layout.indexWhere((item) => item.type == type);
    if (index != -1) {
      _layout[index].isVisible = !_layout[index].isVisible;
      await _saveLayout();
      notifyListeners();
    }
  }

  Future<void> updateOrder(int oldIndex, int newIndex) async {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    // We are reordering the SORTED list. We need to reflect this in the underlying list orders.
    // Actually, simply manipulating the sorted list and reassigning 'order' field is easier.

    final sortedList = allWidgets;
    final item = sortedList.removeAt(oldIndex);
    sortedList.insert(newIndex, item);

    // Update order indices
    for (int i = 0; i < sortedList.length; i++) {
      sortedList[i].order = i;
    }

    _layout =
        sortedList; // This might lose original unsorted reference structure but order is what matters.
    await _saveLayout();
    notifyListeners();
  }

  Future<void> _saveLayout() async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = json.encode(_layout.map((e) => e.toJson()).toList());
    await prefs.setString('home_layout', encoded);
  }

  Future<void> resetLayout() async {
    _resetToDefault();
    notifyListeners();
  }
}
