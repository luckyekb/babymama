import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/checklist_item.dart';

class ChecklistProvider with ChangeNotifier {
  List<ChecklistItem> _items = [];
  bool _isInitialized = false;

  List<ChecklistItem> get items => [..._items];
  bool get isInitialized => _isInitialized;

  ChecklistProvider() {
    _loadItems();
  }

  Future<void> _loadItems() async {
    final prefs = await SharedPreferences.getInstance();
    final itemsJson = prefs.getString('checklist_items');

    if (itemsJson != null) {
      final List<dynamic> decoded = jsonDecode(itemsJson);
      _items = decoded.map((json) => ChecklistItem.fromJson(json)).toList();
    } else {
      // Создать дефолтный чек-лист при первом запуске
      _items = _getDefaultChecklist();
      await _saveItems();
    }

    _isInitialized = true;
    notifyListeners();
  }

  Future<void> _saveItems() async {
    final prefs = await SharedPreferences.getInstance();
    final itemsJson = jsonEncode(_items.map((i) => i.toJson()).toList());
    await prefs.setString('checklist_items', itemsJson);
  }

  Future<void> toggleItem(String id) async {
    final index = _items.indexWhere((i) => i.id == id);
    if (index != -1) {
      _items[index] = _items[index].copyWith(isCompleted: !_items[index].isCompleted);
      await _saveItems();
      notifyListeners();
    }
  }

  Future<void> addItem(ChecklistItem item) async {
    _items.add(item);
    await _saveItems();
    notifyListeners();
  }

  Future<void> updateItem(ChecklistItem item) async {
    final index = _items.indexWhere((i) => i.id == item.id);
    if (index != -1) {
      _items[index] = item;
      await _saveItems();
      notifyListeners();
    }
  }

  Future<void> deleteItem(String id) async {
    _items.removeWhere((i) => i.id == id);
    await _saveItems();
    notifyListeners();
  }

  List<ChecklistItem> getItemsByCategory(String category) {
    return _items.where((i) => i.category == category).toList();
  }

  int getCompletedCount() {
    return _items.where((i) => i.isCompleted).length;
  }

  int getTotalCount() {
    return _items.length;
  }

  double getProgress() {
    if (_items.isEmpty) return 0;
    return getCompletedCount() / getTotalCount();
  }

  List<String> getCategories() {
    return _items.map((i) => i.category).toSet().toList()..sort();
  }

  List<ChecklistItem> _getDefaultChecklist() {
    return [
      // Документы
      ChecklistItem(
        id: '1',
        title: 'Паспорт',
        category: 'Документы для роддома',
      ),
      ChecklistItem(
        id: '2',
        title: 'Обменная карта',
        category: 'Документы для роддома',
      ),
      ChecklistItem(
        id: '3',
        title: 'Полис ОМС',
        category: 'Документы для роддома',
      ),
      ChecklistItem(
        id: '4',
        title: 'СНИЛС',
        category: 'Документы для роддома',
      ),

      // Сумка в роддом для мамы
      ChecklistItem(
        id: '5',
        title: 'Халат и ночная рубашка',
        category: 'Сумка для мамы',
      ),
      ChecklistItem(
        id: '6',
        title: 'Тапочки моющиеся',
        category: 'Сумка для мамы',
      ),
      ChecklistItem(
        id: '7',
        title: 'Средства гигиены',
        category: 'Сумка для мамы',
      ),
      ChecklistItem(
        id: '8',
        title: 'Прокладки послеродовые',
        category: 'Сумка для мамы',
      ),
      ChecklistItem(
        id: '9',
        title: 'Бюстгальтер для кормления',
        category: 'Сумка для мамы',
      ),
      ChecklistItem(
        id: '10',
        title: 'Одноразовые трусы',
        category: 'Сумка для мамы',
      ),

      // Для малыша
      ChecklistItem(
        id: '11',
        title: 'Подгузники для новорожденных',
        category: 'Сумка для малыша',
      ),
      ChecklistItem(
        id: '12',
        title: 'Боди/слипы (3-4 шт)',
        category: 'Сумка для малыша',
      ),
      ChecklistItem(
        id: '13',
        title: 'Царапки и носочки',
        category: 'Сумка для малыша',
      ),
      ChecklistItem(
        id: '14',
        title: 'Шапочки (2 шт)',
        category: 'Сумка для малыша',
      ),
      ChecklistItem(
        id: '15',
        title: 'Пеленки',
        category: 'Сумка для малыша',
      ),
      ChecklistItem(
        id: '16',
        title: 'Влажные салфетки',
        category: 'Сумка для малыша',
      ),

      // На выписку
      ChecklistItem(
        id: '17',
        title: 'Комплект на выписку для малыша',
        category: 'На выписку',
      ),
      ChecklistItem(
        id: '18',
        title: 'Автокресло',
        category: 'На выписку',
      ),
      ChecklistItem(
        id: '19',
        title: 'Одежда для мамы на выписку',
        category: 'На выписку',
      ),

      // Подготовка дома
      ChecklistItem(
        id: '20',
        title: 'Кроватка',
        category: 'Подготовка дома',
      ),
      ChecklistItem(
        id: '21',
        title: 'Матрас и постельное белье',
        category: 'Подготовка дома',
      ),
      ChecklistItem(
        id: '22',
        title: 'Пеленальный столик/комод',
        category: 'Подготовка дома',
      ),
      ChecklistItem(
        id: '23',
        title: 'Коляска',
        category: 'Подготовка дома',
      ),
      ChecklistItem(
        id: '24',
        title: 'Одежда для малыша (разные размеры)',
        category: 'Подготовка дома',
      ),
      ChecklistItem(
        id: '25',
        title: 'Средства для купания',
        category: 'Подготовка дома',
      ),
      ChecklistItem(
        id: '26',
        title: 'Аптечка для новорожденного',
        category: 'Подготовка дома',
      ),
    ];
  }
}
