import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/wellness_entry.dart';

class WellnessProvider with ChangeNotifier {
  List<WellnessEntry> _entries = [];
  bool _isInitialized = false;

  List<WellnessEntry> get entries => [..._entries]..sort((a, b) => b.date.compareTo(a.date));
  bool get isInitialized => _isInitialized;

  WellnessProvider() {
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final entriesJson = prefs.getString('wellness_entries');

    if (entriesJson != null) {
      final List<dynamic> decoded = jsonDecode(entriesJson);
      _entries = decoded.map((json) => WellnessEntry.fromJson(json)).toList();
    }

    _isInitialized = true;
    notifyListeners();
  }

  Future<void> _saveEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final entriesJson = jsonEncode(_entries.map((e) => e.toJson()).toList());
    await prefs.setString('wellness_entries', entriesJson);
  }

  Future<void> addEntry(WellnessEntry entry) async {
    _entries.add(entry);
    await _saveEntries();
    notifyListeners();
  }

  Future<void> deleteEntry(String id) async {
    _entries.removeWhere((e) => e.id == id);
    await _saveEntries();
    notifyListeners();
  }

  List<WellnessEntry> getEntriesWithWeight() {
    return _entries.where((e) => e.weight != null).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  double? getLatestWeight() {
    final entriesWithWeight = getEntriesWithWeight();
    return entriesWithWeight.isEmpty ? null : entriesWithWeight.last.weight;
  }

  WellnessEntry? getEntryForDate(DateTime date) {
    try {
      return _entries.firstWhere((e) =>
          e.date.year == date.year &&
          e.date.month == date.month &&
          e.date.day == date.day);
    } catch (e) {
      return null;
    }
  }
}
