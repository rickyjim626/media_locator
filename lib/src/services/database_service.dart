import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/project.dart';
import '../models/media_file.dart';
import '../models/disk.dart';
import 'package:logger/logger.dart';  // 添加 Logger

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  late Database _database;
  final Logger _logger = Logger();  // 实例化 Logger

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
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            path TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE media_files(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
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
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            path TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE disks(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            path TEXT,
            isMounted INTEGER,
            lastChecked TEXT
          )
        ''');
        _logger.i("Database tables created successfully");
      },
      version: 1,
    );

    _logger.i("Database initialized at $path");
  }

  Future<List<Project>> loadProjects() async {
    final List<Map<String, dynamic>> maps = await _database.query('projects');
    _logger.i("Loaded projects: ${maps.length}");
    return maps.map((map) => Project.fromMap(map)).toList();
  }

  Future<void> addProject(Project project) async {
    await _database.insert('projects', {
      'name': project.name,
      'path': project.path,
    });
    _logger.i("Added project: ${project.name}, ${project.path}");
  }

  Future<List<MediaFile>> loadFilesFromProject(int projectId) async {
    final List<Map<String, dynamic>> maps = await _database.query(
      'media_files',
      where: 'project_id = ?',
      whereArgs: [projectId],
    );
    _logger.i("Loaded media files for project $projectId: ${maps.length}");
    return maps.map((map) => MediaFile.fromMap(map)).toList();
  }

  Future<void> addFiles(List<MediaFile> files) async {
    await _database.transaction((txn) async {
      for (final file in files) {
        await txn.insert('media_files', file.toMap());
        _logger.i("Added media file: ${file.name}, ${file.path}");
      }
    });
  }

  Future<void> addException(String path) async {
    await _database.insert('exceptions', {'path': path});
    _logger.i("Added exception: $path");
  }

  Future<List<String>> loadExceptions() async {
    final List<Map<String, dynamic>> maps = await _database.query('exceptions');
    _logger.i("Loaded exceptions: ${maps.length}");
    return maps.map((map) => map['path'].toString()).toList();
  }

  Future<List<Disk>> loadDisks() async {
    final List<Map<String, dynamic>> maps = await _database.query('disks');
    _logger.i("Loaded disks: ${maps.length}");
    return maps.map((map) => Disk.fromMap(map)).toList();
  }

  Future<void> addDisk(Disk disk) async {
    await _database.insert('disks', disk.toMap());
    _logger.i("Added disk: ${disk.name}, ${disk.path}");
  }
}