import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/pregnancy_data.dart';
import '../models/pregnancy_week.dart';

class PregnancyProvider with ChangeNotifier {
  DateTime? _dueDate;
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;
  bool get hasPregnancyDate => _dueDate != null;
  DateTime? get dueDate => _dueDate;

  PregnancyProvider() {
    _loadPregnancyDate();
  }

  Future<void> _loadPregnancyDate() async {
    final prefs = await SharedPreferences.getInstance();
    final savedDate = prefs.getString('due_date');

    if (savedDate != null) {
      _dueDate = DateTime.parse(savedDate);
    }

    _isInitialized = true;
    notifyListeners();
  }

  Future<void> setDueDate(DateTime date) async {
    _dueDate = date;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('due_date', date.toIso8601String());
    notifyListeners();
  }

  Future<void> setLastPeriodDate(DateTime lastPeriodDate) async {
    // Срок беременности = дата последней менструации + 280 дней (40 недель)
    final dueDate = lastPeriodDate.add(const Duration(days: 280));
    await setDueDate(dueDate);
  }

  int getCurrentWeek() {
    if (_dueDate == null) return 0;

    final today = DateTime.now();
    final daysSinceConception = _dueDate!.difference(today).inDays;
    final weeksRemaining = (daysSinceConception / 7).floor();
    final currentWeek = 40 - weeksRemaining;

    // Ограничиваем неделю от 1 до 40
    return currentWeek.clamp(1, 40);
  }

  int getDaysInCurrentWeek() {
    if (_dueDate == null) return 0;

    final today = DateTime.now();
    final daysSinceConception = _dueDate!.difference(today).inDays;
    final daysInWeek = 7 - (daysSinceConception % 7);

    return daysInWeek.clamp(0, 7);
  }

  PregnancyWeek getCurrentWeekData() {
    final weekNumber = getCurrentWeek();
    return pregnancyWeeksData[weekNumber - 1];
  }

  PregnancyWeek getWeekData(int weekNumber) {
    if (weekNumber < 1 || weekNumber > 40) {
      return pregnancyWeeksData[0];
    }
    return pregnancyWeeksData[weekNumber - 1];
  }

  String getWeeksRemainingText() {
    if (_dueDate == null) return '';

    final today = DateTime.now();
    final weeksRemaining = (_dueDate!.difference(today).inDays / 7).floor();

    if (weeksRemaining <= 0) {
      return 'Скоро встреча!';
    }

    return '$weeksRemaining ${_getWeekWord(weeksRemaining)} до родов';
  }

  String _getWeekWord(int weeks) {
    if (weeks % 10 == 1 && weeks % 100 != 11) {
      return 'неделя';
    } else if ([2, 3, 4].contains(weeks % 10) && ![12, 13, 14].contains(weeks % 100)) {
      return 'недели';
    } else {
      return 'недель';
    }
  }
}
