import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

// Database table and column names.
final String tableBlockedApps = 'blockedapps';
final String columnId = '_id';
final String columnPackageName = 'packagename';

// Database table and column names for storing the pin.
final String tablePin = 'pintable';
final String columnPinId = '_id';
final String columnPinString = 'pinstring';

// Data model class for storing the blocked apps.
class BlockedApps {
  int id;
  String packageName;

  BlockedApps();

  // Convenience constructor to create a BlockedApp object
  BlockedApps.fromMap(Map<String, dynamic> map) {
    id = map[columnId];
    packageName = map[columnPackageName];
  }
}

// Singleton class to manage the database
class DatabaseHelper {
  // This is the actual database filename that is saved in the application directory.
  static final _databaseName = 'AppLocker.db';
  // Increment this version when you need to change the schema.
  static final _databaseVersion = 1;

  // Make this a singleton class.
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  // Only allow a single open connection to the database.
  static Database _database;

  Future<Database> get database async {
    if (_database != null) return _database;
    _database = await _initDatabase();
    return _database;
  }

  // open the database
  _initDatabase() async {
    // The path_provider plugin gets the right directory for Android or iOS.
    Directory documentsDirectory = await getApplicationSupportDirectory();
    String path = join(
        documentsDirectory.path
                .substring(0, documentsDirectory.path.lastIndexOf('files')) +
            'databases/',
        _databaseName);
    // Open the database. Can also add an onUpdate callback parameter.
    return await openDatabase(path,
        version: _databaseVersion, onCreate: _onCreate);
  }

  // SQL string to create the tables.

  // Create table 'pintable' to store the pin selected by the user.
  Future _onCreate(Database db, int version) async {
    await db.execute('''
              CREATE TABLE $tablePin (
                $columnPinId INTEGER PRIMARY KEY,
                $columnPinString TEXT NOT NULL
              )
              ''');

    // Create table 'blockedapps' to store all the apps which the user wants to block access.
    await db.execute('''
              CREATE TABLE $tableBlockedApps (
                $columnId INTEGER PRIMARY KEY,
                $columnPackageName TEXT NOT NULL
              )
              ''');
  }

  // Check if pins are saved in the 'pintable'
  Future<bool> checkTablePinIsEmpty() async {
    Database db = await database;
    List<Map> maps = await db.query(tablePin);
    print('Printing the values in pintable ###########');
    if (maps.length > 0) {
      print('Rows found');
      //await db.close();
      return false;
    } else {
      print('No Rows found');
      //await db.close();
      return true;
    }
  }

  // Insert the user supplied pins in the 'pintable'
  // Database helper methods:
  Future<int> insertPin(String pin) async {
    Database db = await database;

    // Delete existing pin from the table.
    await db.delete(tablePin);
    Map<String, dynamic> suppliedPin = {'pinstring': pin};
    int id = await db.insert(tablePin, suppliedPin);
    return id;
  }

  // Check to see the list of blocked apps
  Future<List<BlockedApps>> queryBlockedApps() async {
    Database db = await database;
    List<BlockedApps> listOfBlockedApps = List<BlockedApps>();
    List<Map> maps = await db.query(tableBlockedApps);
    if (maps.length > 0) {
      for (var item in maps) {
        print(item);
        BlockedApps objBlockedApps = BlockedApps.fromMap(item);
        listOfBlockedApps.add(objBlockedApps);
      }
    }

    //await db.close();
    return listOfBlockedApps;
  }

  // Authenticate the application by checking the pin which the user has entered
  // if the application is locked.
  Future<bool> checkPin(String pin) async {
    Database db = await database;
    List<Map> maps = await db.query(tablePin);
    if (maps[0]["pinstring"] == pin) {
      return true;
    } else {
      return false;
    }
  }
}
