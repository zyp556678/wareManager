import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/clothing_item.dart';
import '../models/outfit.dart';
import '../models/outfit_log.dart';
import '../models/location.dart';
import '../models/operation_log.dart';

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
      version: 8,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 5) {
      await db.execute('ALTER TABLE locations ADD COLUMN latitude REAL');
      await db.execute('ALTER TABLE locations ADD COLUMN longitude REAL');
    }
    if (oldVersion < 6) {
      try {
        await db.execute('ALTER TABLE locations DROP COLUMN latitude');
      } catch (_) {}
      try {
        await db.execute('ALTER TABLE locations DROP COLUMN longitude');
      } catch (_) {}
      await db.execute('ALTER TABLE locations ADD COLUMN address TEXT');
    }
    if (oldVersion < 7) {
      await db.execute('ALTER TABLE clothing_items ADD COLUMN idleFrom INTEGER');
    }
    if (oldVersion < 8) {
      await db.execute('''
        CREATE TABLE chat_sessions (
          id TEXT PRIMARY KEY,
          title TEXT NOT NULL,
          createdDate INTEGER NOT NULL,
          lastMessageDate INTEGER NOT NULL
        )
      ''');
      await db.execute('''
        CREATE TABLE chat_messages (
          id TEXT PRIMARY KEY,
          sessionId TEXT NOT NULL,
          role TEXT NOT NULL,
          text TEXT,
          imagePath TEXT,
          clothingIds TEXT,
          timestamp INTEGER NOT NULL,
          FOREIGN KEY (sessionId) REFERENCES chat_sessions(id)
        )
      ''');
    }
  }

  Future<void> _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const integerType = 'INTEGER NOT NULL';

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
        idleFrom INTEGER,
        idleUntil INTEGER,
        storageLocation TEXT,
        createdDate $integerType
      )
    ''');

    await db.execute('''
      CREATE TABLE outfits (
        id $idType,
        clothingIds $textType,
        styleTag $textType,
        createdDate $integerType,
        timesWorn $integerType DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE outfit_logs (
        id $idType,
        outfitId $integerType,
        date $integerType,
        weather $textType,
        occasion $textType
      )
    ''');

    await db.execute('''
      CREATE TABLE locations (
        id $idType,
        name $textType,
        type $textType,
        description TEXT,
        address TEXT,
        createdAt $integerType
      )
    ''');

    await db.execute('''
      CREATE TABLE operation_logs (
        id $idType,
        type $textType,
        clothing_id INTEGER,
        clothing_name TEXT,
        content TEXT,
        extra TEXT,
        created_at $integerType
      )
    ''');

    await db.execute('''
      CREATE TABLE chat_sessions (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        createdDate INTEGER NOT NULL,
        lastMessageDate INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE chat_messages (
        id TEXT PRIMARY KEY,
        sessionId TEXT NOT NULL,
        role TEXT NOT NULL,
        text TEXT,
        imagePath TEXT,
        clothingIds TEXT,
        timestamp INTEGER NOT NULL,
        FOREIGN KEY (sessionId) REFERENCES chat_sessions(id)
      )
    ''');
  }

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
    return await db.update(
      'clothing_items',
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  Future<int> deleteClothingItem(int id) async {
    final db = await database;
    return await db.delete(
      'clothing_items',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> createOutfit(Outfit outfit) async {
    final db = await database;
    return await db.insert('outfits', outfit.toMap());
  }

  Future<List<Outfit>> getAllOutfits() async {
    final db = await database;
    final result = await db.query('outfits', orderBy: 'createdDate DESC');
    return result.map((map) => Outfit.fromMap(map)).toList();
  }

  Future<int> createOutfitLog(OutfitLog log) async {
    final db = await database;
    return await db.insert('outfit_logs', log.toMap());
  }

  Future<List<OutfitLog>> getOutfitLogsByMonth(DateTime month) async {
    final db = await database;
    final startOfMonth = DateTime(month.year, month.month, 1);
    final endOfMonth = DateTime(month.year, month.month + 1, 0, 23, 59, 59);
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

  Future<int> createOperationLog(OperationLog log) async {
    final db = await database;
    return await db.insert('operation_logs', log.toMap());
  }

  Future<List<OperationLog>> getAllOperationLogs() async {
    final db = await database;
    final result = await db.query('operation_logs', orderBy: 'created_at DESC');
    return result.map((map) => OperationLog.fromMap(map)).toList();
  }

  Future<List<OperationLog>> getOperationLogsByMonth(DateTime month) async {
    final db = await database;
    final startOfMonth = DateTime(month.year, month.month, 1);
    final endOfMonth = DateTime(month.year, month.month + 1, 0, 23, 59, 59);
    final result = await db.query(
      'operation_logs',
      where: 'created_at >= ? AND created_at <= ?',
      whereArgs: [
        startOfMonth.millisecondsSinceEpoch,
        endOfMonth.millisecondsSinceEpoch,
      ],
      orderBy: 'created_at DESC',
    );
    return result.map((map) => OperationLog.fromMap(map)).toList();
  }

  // ========== AI 对话 ==========

  Future<String> createChatSession(String id, String title) async {
    final db = await database;
    await db.insert('chat_sessions', {
      'id': id,
      'title': title,
      'createdDate': DateTime.now().millisecondsSinceEpoch,
      'lastMessageDate': DateTime.now().millisecondsSinceEpoch,
    });
    return id;
  }

  Future<void> updateSessionLastMessage(String sessionId) async {
    final db = await database;
    await db.update(
      'chat_sessions',
      {'lastMessageDate': DateTime.now().millisecondsSinceEpoch},
      where: 'id = ?',
      whereArgs: [sessionId],
    );
  }

  Future<void> updateSessionTitle(String sessionId, String title) async {
    final db = await database;
    await db.update(
      'chat_sessions',
      {'title': title},
      where: 'id = ?',
      whereArgs: [sessionId],
    );
  }

  Future<List<Map<String, dynamic>>> getChatSessions() async {
    final db = await database;
    return await db.query('chat_sessions', orderBy: 'lastMessageDate DESC');
  }

  Future<void> deleteChatSession(String sessionId) async {
    final db = await database;
    await db.delete('chat_messages', where: 'sessionId = ?', whereArgs: [sessionId]);
    await db.delete('chat_sessions', where: 'id = ?', whereArgs: [sessionId]);
  }

  Future<void> insertChatMessage(Map<String, dynamic> message) async {
    final db = await database;
    await db.insert('chat_messages', message);
  }

  Future<List<Map<String, dynamic>>> getChatMessages(String sessionId) async {
    final db = await database;
    return await db.query(
      'chat_messages',
      where: 'sessionId = ?',
      whereArgs: [sessionId],
      orderBy: 'timestamp ASC',
    );
  }

  Future<void> close() async {
    final db = await database;
    db.close();
  }
}