import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/doctor_visit.dart';

class DoctorDiaryProvider with ChangeNotifier {
  List<DoctorVisit> _visits = [];
  bool _isInitialized = false;

  List<DoctorVisit> get visits => [..._visits]..sort((a, b) => b.date.compareTo(a.date));
  bool get isInitialized => _isInitialized;

  DoctorDiaryProvider() {
    _loadVisits();
  }

  Future<void> _loadVisits() async {
    final prefs = await SharedPreferences.getInstance();
    final visitsJson = prefs.getString('doctor_visits');

    if (visitsJson != null) {
      final List<dynamic> decoded = jsonDecode(visitsJson);
      _visits = decoded.map((json) => DoctorVisit.fromJson(json)).toList();
    }

    _isInitialized = true;
    notifyListeners();
  }

  Future<void> _saveVisits() async {
    final prefs = await SharedPreferences.getInstance();
    final visitsJson = jsonEncode(_visits.map((v) => v.toJson()).toList());
    await prefs.setString('doctor_visits', visitsJson);
  }

  Future<void> addVisit(DoctorVisit visit) async {
    _visits.add(visit);
    await _saveVisits();
    notifyListeners();
  }

  Future<void> updateVisit(DoctorVisit visit) async {
    final index = _visits.indexWhere((v) => v.id == visit.id);
    if (index != -1) {
      _visits[index] = visit;
      await _saveVisits();
      notifyListeners();
    }
  }

  Future<void> deleteVisit(String id) async {
    _visits.removeWhere((v) => v.id == id);
    await _saveVisits();
    notifyListeners();
  }

  DoctorVisit? getVisitById(String id) {
    try {
      return _visits.firstWhere((v) => v.id == id);
    } catch (e) {
      return null;
    }
  }

  List<DoctorVisit> getUpcomingVisits() {
    final now = DateTime.now();
    return _visits.where((v) => v.date.isAfter(now)).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  List<DoctorVisit> getPastVisits() {
    final now = DateTime.now();
    return _visits.where((v) => v.date.isBefore(now)).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }
}
