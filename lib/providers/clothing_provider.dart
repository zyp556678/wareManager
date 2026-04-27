import 'package:flutter/foundation.dart';
import '../models/clothing_item.dart';
import '../services/database_helper.dart';

class ClothingProvider with ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  List<ClothingItem> _clothingItems = [];
  bool _isLoading = false;

  List<ClothingItem> get clothingItems => _clothingItems;
  bool get isLoading => _isLoading;

  // 获取活跃衣物
  List<ClothingItem> get activeClothing =>
      _clothingItems.where((item) => item.status == 'active').toList();

  // 获取闲置衣物
  List<ClothingItem> get idleClothing =>
      _clothingItems.where((item) => item.status == 'idle').toList();

  // 加载所有衣物
  Future<void> loadClothingItems() async {
    _isLoading = true;
    notifyListeners();

    try {
      _clothingItems = await _dbHelper.getAllClothingItems();
    } catch (e) {
      print('Error loading clothing items: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  // 添加衣物
  Future<void> addClothingItem(ClothingItem item) async {
    try {
      final id = await _dbHelper.createClothingItem(item);
      final newItem = item.copyWith(id: id);
      _clothingItems.insert(0, newItem);
      notifyListeners();
    } catch (e) {
      print('Error adding clothing item: $e');
    }
  }

  // 更新衣物
  Future<void> updateClothingItem(ClothingItem item) async {
    try {
      await _dbHelper.updateClothingItem(item);
      final index = _clothingItems.indexWhere((c) => c.id == item.id);
      if (index != -1) {
        _clothingItems[index] = item;
        notifyListeners();
      }
    } catch (e) {
      print('Error updating clothing item: $e');
    }
  }

  // 删除衣物
  Future<void> deleteClothingItem(int id) async {
    try {
      await _dbHelper.deleteClothingItem(id);
      _clothingItems.removeWhere((item) => item.id == id);
      notifyListeners();
    } catch (e) {
      print('Error deleting clothing item: $e');
    }
  }

  // 按品类筛选
  List<ClothingItem> getByCategory(String category) {
    return _clothingItems
        .where((item) => item.category == category && item.status == 'active')
        .toList();
  }

  // 设置衣物为闲置
  Future<void> setIdle(int id, DateTime until, String location) async {
    try {
      print('DEBUG: Setting item $id as idle');
      final index = _clothingItems.indexWhere((c) => c.id == id);
      if (index == -1) {
        print('Error: Clothing item with id $id not found');
        return;
      }
      
      final item = _clothingItems[index];
      print('DEBUG: Found item: ${item.category}, current status: ${item.status}');
      
      final updatedItem = item.copyWith(
        status: 'idle',
        idleUntil: until,
        storageLocation: location,
      );
      
      print('DEBUG: Updated item status to: ${updatedItem.status}');
      await updateClothingItem(updatedItem);
      print('DEBUG: Successfully updated item in database');
      
      // 强制刷新列表
      await loadClothingItems();
      print('DEBUG: Reloaded clothing items list');
    } catch (e) {
      print('Error setting item as idle: $e');
    }
  }

  // 唤醒闲置衣物
  Future<void> wakeUpIdle(int id) async {
    final item = _clothingItems.firstWhere((c) => c.id == id);
    final updatedItem = item.copyWith(
      status: 'active',
      idleUntil: null,
      storageLocation: '',
    );
    await updateClothingItem(updatedItem);
  }
}
