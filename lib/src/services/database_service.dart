import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/project.dart';
import '../models/media_file.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  late Database _database;

  factory DatabaseService() {
    return _instance;
  }

  DatabaseService._internal();

  Future<void> initialize() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'media_locator.db');

    _database = await openDatabase(
      path,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE projects(
            id INTEGER PRIMARY KEY,
            name TEXT,
            path TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE media_files(
            id INTEGER PRIMARY KEY,
            name TEXT,
            size INTEGER,
            type TEXT,
            path TEXT,
            project_id INTEGER,
            FOREIGN KEY(project_id) REFERENCES projects(id)
          )
        ''');
        await db.execute('''
          CREATE TABLE exceptions(
            id INTEGER PRIMARY KEY,
            path TEXT
          )
        ''');
      },
      version: 1,
    );
  }

  Future<List<Project>> loadProjects() async {
    final List<Map<String, dynamic>> maps = await _database.query('projects');
    return maps.map((map) => Project.fromMap(map)).toList();
  }

  Future<void> addProject(Project project) async {
    await _database.insert('projects', project.toMap());
  }

  Future<List<MediaFile>> loadFilesFromProject(int projectId) async {
    final List<Map<String, dynamic>> maps = await _database.query(
      'media_files',
      where: 'project_id = ?',
      whereArgs: [projectId],
    );
    return maps.map((map) => MediaFile.fromMap(map)).toList();
  }

  Future<void> addFiles(List<MediaFile> files) async {
    await _database.transaction((txn) async {
      for (final file in files) {
        await txn.insert('media_files', file.toMap());
      }
    });
  }

  Future<void> addException(String path) async {
    await _database.insert('exceptions', {'path': path});
  }

  Future<List<String>> loadExceptions() async {
    final List<Map<String, dynamic>> maps = await _database.query('exceptions');
    return maps.map((map) => map['path'].toString()).toList();
  }
}