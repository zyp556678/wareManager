import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart';
import '../models/clothing_item.dart';
import '../models/outfit.dart';
import '../models/outfit_log.dart';
import '../models/location.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('wearwise.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const integerType = 'INTEGER NOT NULL';

    // 衣物表
    await db.execute('''
      CREATE TABLE clothing_items (
        id $idType,
        imagePath $textType,
        category $textType,
        color $textType,
        material $textType,
        style $textType,
        season TEXT,
        customTags TEXT,
        status TEXT DEFAULT 'active',
        idleUntil INTEGER,
        storageLocation TEXT,
        createdDate $integerType
      )
    ''');

    // 穿搭表
    await db.execute('''
      CREATE TABLE outfits (
        id $idType,
        clothingIds $textType,
        styleTag $textType,
        createdDate $integerType,
        timesWorn $integerType DEFAULT 0
      )
    ''');

    // 穿搭日志表
    await db.execute('''
      CREATE TABLE outfit_logs (
        id $idType,
        outfitId $integerType,
        date $integerType,
        weather $textType,
        occasion $textType
      )
    ''');

    // 地点表
    await db.execute('''
      CREATE TABLE locations (
        id $idType,
        name $textType,
        type $textType,
        description TEXT,
        createdAt $integerType
      )
    ''');
  }

  // ClothingItem CRUD
  Future<int> createClothingItem(ClothingItem item) async {
    final db = await database;
    return await db.insert('clothing_items', item.toMap());
  }

  Future<List<ClothingItem>> getAllClothingItems() async {
    final db = await database;
    final result = await db.query('clothing_items', orderBy: 'createdDate DESC');
    return result.map((map) => ClothingItem.fromMap(map)).toList();
  }

  Future<List<ClothingItem>> getClothingByCategory(String category) async {
    final db = await database;
    final result = await db.query(
      'clothing_items',
      where: 'category = ?',
      whereArgs: [category],
      orderBy: 'createdDate DESC',
    );
    return result.map((map) => ClothingItem.fromMap(map)).toList();
  }

  Future<List<ClothingItem>> getIdleClothingItems() async {
    final db = await database;
    final result = await db.query(
      'clothing_items',
      where: 'status = ?',
      whereArgs: ['idle'],
      orderBy: 'idleUntil ASC',
    );
    return result.map((map) => ClothingItem.fromMap(map)).toList();
  }

  Future<int> updateClothingItem(ClothingItem item) async {
    final db = await database;
    debugPrint('DEBUG DB: Updating item ${item.id} with status: ${item.status}');
    final result = await db.update(
      'clothing_items',
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
    debugPrint('DEBUG DB: Update result: $result rows affected');
    return result;
  }

  Future<int> deleteClothingItem(int id) async {
    final db = await database;
    return await db.delete(
      'clothing_items',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Outfit CRUD
  Future<int> createOutfit(Outfit outfit) async {
    final db = await database;
    return await db.insert('outfits', outfit.toMap());
  }

  Future<List<Outfit>> getAllOutfits() async {
    final db = await database;
    final result = await db.query('outfits', orderBy: 'createdDate DESC');
    return result.map((map) => Outfit.fromMap(map)).toList();
  }

  // OutfitLog CRUD
  Future<int> createOutfitLog(OutfitLog log) async {
    final db = await database;
    return await db.insert('outfit_logs', log.toMap());
  }

  Future<List<OutfitLog>> getOutfitLogsByMonth(DateTime month) async {
    final db = await database;
    final startOfMonth = DateTime(month.year, month.month, 1);
    final endOfMonth = DateTime(month.year, month.month + 1, 0);
    
    final result = await db.query(
      'outfit_logs',
      where: 'date >= ? AND date <= ?',
      whereArgs: [
        startOfMonth.millisecondsSinceEpoch,
        endOfMonth.millisecondsSinceEpoch,
      ],
      orderBy: 'date DESC',
    );
    return result.map((map) => OutfitLog.fromMap(map)).toList();
  }

  // Location CRUD
  Future<int> createLocation(Location location) async {
    final db = await database;
    return await db.insert('locations', location.toMap());
  }

  Future<List<Location>> getAllLocations() async {
    final db = await database;
    final result = await db.query('locations', orderBy: 'createdAt DESC');
    return result.map((map) => Location.fromMap(map)).toList();
  }

  Future<int> updateLocation(Location location) async {
    final db = await database;
    return await db.update(
      'locations',
      location.toMap(),
      where: 'id = ?',
      whereArgs: [location.id],
    );
  }

  Future<int> deleteLocation(int id) async {
    final db = await database;
    return await db.delete(
      'locations',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> close() async {
    final db = await database;
    db.close();
  }
}
