import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import '../../features/buildings/data/building_model.dart';

class LocalDatabaseService {
  static final LocalDatabaseService instance = LocalDatabaseService._init();
  static Database? _database;

  LocalDatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('mappka_local.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getApplicationDocumentsDirectory();
    final path = join(dbPath.path, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE buildings (
        id TEXT PRIMARY KEY,
        minLat REAL,
        maxLat REAL,
        minLng REAL,
        maxLng REAL,
        coordinates TEXT
      )
    ''');

    await db.execute('CREATE INDEX idx_minLat ON buildings (minLat)');
    await db.execute('CREATE INDEX idx_maxLat ON buildings (maxLat)');
    await db.execute('CREATE INDEX idx_minLng ON buildings (minLng)');
    await db.execute('CREATE INDEX idx_maxLng ON buildings (maxLng)');

    await db.execute('''
      CREATE TABLE unlocked_buildings (
        id TEXT PRIMARY KEY
      )
    ''');
  }

  Future<void> insertBuildings(List<Building> buildings) async {
    final db = await instance.database;
    final batch = db.batch();

    for (var building in buildings) {
      batch.insert(
        'buildings',
        building.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace, 
      );
    }

    await batch.commit(noResult: true);
  }

  Future<List<Building>> getBuildingsInBounds({
    required double minLat,
    required double maxLat,
    required double minLng,
    required double maxLng,
  }) async {
    final db = await instance.database;
    final maps = await db.query(
      'buildings',
      where: 'maxLat >= ? AND minLat <= ? AND maxLng >= ? AND minLng <= ?',
      whereArgs: [minLat, maxLat, minLng, maxLng],
    );

    return maps.map((map) => Building.fromMap(map)).toList();
  }

  Future<void> unlockBuilding(String id) async {
    final db = await instance.database;
    await db.insert(
      'unlocked_buildings',
      {'id': id},
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<List<String>> getUnlockedBuildingIds() async {
    final db = await instance.database;
    final result = await db.query('unlocked_buildings');
    return result.map((row) => row['id'] as String).toList();
  }
}