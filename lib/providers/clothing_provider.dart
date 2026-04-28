import 'package:flutter/foundation.dart';
import '../models/clothing_item.dart';
import '../models/operation_log.dart';
import '../services/database_helper.dart';

class ClothingProvider with ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  List<ClothingItem> _clothingItems = [];
  List<OperationLog> _operationLogs = [];
  List<ClothingItem> _activeClothing = [];
  List<ClothingItem> _idleClothing = [];
  bool _isLoading = false;

  List<ClothingItem> get clothingItems => _clothingItems;
  List<OperationLog> get operationLogs => _operationLogs;
  bool get isLoading => _isLoading;

  List<ClothingItem> get activeClothing => _activeClothing;
  List<ClothingItem> get idleClothing => _idleClothing;

  void _rebuildCache() {
    _activeClothing = _clothingItems.where((item) => item.status == 'active').toList();
    _idleClothing = _clothingItems.where((item) => item.status == 'idle').toList();
  }

  Future<void> loadClothingItems() async {
    _isLoading = true;
    notifyListeners();

    try {
      _clothingItems = await _dbHelper.getAllClothingItems();
      _operationLogs = await _dbHelper.getAllOperationLogs();
      _activeClothing = _clothingItems.where((item) => item.status == 'active').toList();
      _idleClothing = _clothingItems.where((item) => item.status == 'idle').toList();
    } catch (e) {
      debugPrint('Error loading data: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addOperationLog(OperationLog log) async {
    try {
      final id = await _dbHelper.createOperationLog(log);
      final newLog = OperationLog(
        id: id,
        type: log.type,
        clothingId: log.clothingId,
        clothingName: log.clothingName,
        content: log.content,
        extra: log.extra,
        createdAt: log.createdAt,
      );
      _operationLogs.insert(0, newLog);
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding operation log: $e');
    }
  }

  Future<void> addClothingItem(ClothingItem item) async {
    try {
      final id = await _dbHelper.createClothingItem(item);
      final newItem = item.copyWith(id: id);
      _clothingItems.insert(0, newItem);
      _rebuildCache();

      await addOperationLog(OperationLog(
        type: 'add',
        clothingId: id,
        clothingName: '${item.category} · ${item.color}',
        content: '新增衣物',
        createdAt: DateTime.now(),
      ));

      notifyListeners();
    } catch (e) {
      debugPrint('Error adding clothing item: $e');
    }
  }

  Future<void> updateClothingItem(ClothingItem item) async {
    try {
      await _dbHelper.updateClothingItem(item);
      final index = _clothingItems.indexWhere((c) => c.id == item.id);
      if (index != -1) {
        _clothingItems[index] = item;
        _rebuildCache();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error updating clothing item: $e');
    }
  }

  Future<void> deleteClothingItem(int id) async {
    final item = _clothingItems.firstWhere((c) => c.id == id);
    await _dbHelper.deleteClothingItem(id);
    _clothingItems.removeWhere((c) => c.id == id);
    _rebuildCache();

    await addOperationLog(OperationLog(
      type: 'delete',
      clothingId: id,
      clothingName: '${item.category} · ${item.color}',
      content: '删除衣物',
      createdAt: DateTime.now(),
    ));

    notifyListeners();
  }

  List<ClothingItem> getByCategory(String category) {
    return _clothingItems
        .where((item) => item.category == category && item.status == 'active')
        .toList();
  }

  Future<void> setIdle(int id, DateTime until, String location) async {
    try {
      final index = _clothingItems.indexWhere((c) => c.id == id);
      if (index == -1) {
        debugPrint('Error: Clothing item with id $id not found');
        return;
      }

      final item = _clothingItems[index];
      final updatedItem = item.copyWith(
        status: 'idle',
        idleUntil: until,
        storageLocation: location,
      );

      await updateClothingItem(updatedItem);

      final dateStr = '${until.year}-${until.month.toString().padLeft(2, '0')}-${until.day.toString().padLeft(2, '0')}';
      await addOperationLog(OperationLog(
        type: 'idle',
        clothingId: id,
        clothingName: '${item.category} · ${item.color}',
        content: '设为闲置',
        extra: '闲置至 $dateStr，存放在 $location',
        createdAt: DateTime.now(),
      ));

      await loadClothingItems();
    } catch (e) {
      debugPrint('Error setting item as idle: $e');
    }
  }

  Future<void> wakeUpIdle(int id) async {
    final item = _clothingItems.firstWhere((c) => c.id == id);
    final updatedItem = item.copyWith(
      status: 'active',
      idleUntil: null,
      storageLocation: '',
    );
    await updateClothingItem(updatedItem);

    await addOperationLog(OperationLog(
      type: 'wakeup',
      clothingId: id,
      clothingName: '${item.category} · ${item.color}',
      content: '唤醒衣物',
      createdAt: DateTime.now(),
    ));
  }
}