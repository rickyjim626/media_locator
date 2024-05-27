import 'package:flutter/material.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('媒体定位器'),
        ),
        body: const MediaLocator(),
      ),
    );
  }
}

class MediaLocator extends StatefulWidget {
  const MediaLocator({super.key});

  @override
  _MediaLocatorState createState() => _MediaLocatorState();
}

class _MediaLocatorState extends State<MediaLocator> {
  final List<Project> _projects = [];
  final List<Disk> _disks = [];
  Project? _selectedProject;
  List<MediaFile> _mediaFiles = [];
  late Database _database;
  final List<String> _exceptions = [];

  @override
  void initState() {
    super.initState();
    _initializeDatabase();
    _loadDisks();
  }

  Future<void> _initializeDatabase() async {
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

    await _loadProjects();
    await _loadExceptions();
  }

  Future<void> _loadProjects() async {
    final List<Map<String, dynamic>> maps = await _database.query('projects');
    setState(() {
      _projects.clear();
      _projects.addAll(maps.map((map) => Project.fromMap(map)).toList());
      if (_projects.isNotEmpty) {
        _selectedProject = _projects.first;
        _loadFilesFromProject(_selectedProject!.id);
      }
    });
  }

  Future<void> _loadExceptions() async {
    final List<Map<String, dynamic>> maps = await _database.query('exceptions');
    setState(() {
      _exceptions.clear();
      _exceptions.addAll(maps.map((map) => map['path'].toString()).toList());
    });
  }

  Future<void> _addException(String path) async {
    await _database.insert('exceptions', {'path': path});
    setState(() {
      _exceptions.add(path);
    });
  }

  Future<void> _addProject(String name, String path) async {
    final id = await _database.insert('projects', {'name': name, 'path': path});
    setState(() {
      final project = Project(id: id, name: name, path: path);
      _projects.add(project);
      _selectedProject = project;
      _loadFilesFromProject(project.id);
    });
  }

  Future<void> _loadFilesFromProject(int projectId) async {
    final List<Map<String, dynamic>> maps = await _database.query(
      'media_files',
      where: 'project_id = ?',
      whereArgs: [projectId],
    );
    setState(() {
      _mediaFiles = maps.map((map) => MediaFile.fromMap(map)).toList();
    });
  }

  Future<void> _scanDirectory(Project project) async {
    final List<String> extensions = ['mp4', 'mov', 'avi'];
    final List<MediaFile> files = await scanDirectory(project.path, project.id, extensions);
    await _database.transaction((txn) async {
      for (final file in files) {
        await txn.insert('media_files', file.toMap());
      }
    });
    _loadFilesFromProject(project.id);
  }

  Future<List<MediaFile>> scanDirectory(String path, int projectId, List<String> extensions) async {
    final List<MediaFile> filePaths = [];
    final directory = Directory(path);

    await for (var entity in directory.list(recursive: true, followLinks: false)) {
      if (entity is Directory && _exceptions.contains(entity.path)) {
        print('检测到例外: ${entity.path}');
        continue;
      }
      if (entity is File) {
        final fileType = entity.path.split('.').last.toLowerCase();
        if (extensions.contains(fileType)) {
          final fileStats = await entity.stat();
          filePaths.add(MediaFile(
            id: null,
            name: entity.path.split('/').last,
            size: fileStats.size,
            type: fileType,
            path: entity.path,
            projectId: projectId,
          ));
        }
      }
    }

    return filePaths;
  }

  Future<void> _loadDisks() async {
    final result = await Process.run('df', ['-h']);
    final lines = result.stdout.toString().split('\n');
    final disks = <Disk>[];

    for (var line in lines.skip(1)) {
      final parts = line.split(RegExp(r'\s+'));
      if (parts.length > 5) {
        final name = parts[0];
        final path = parts[5];
        final isOnline = Directory(path).existsSync();
        disks.add(Disk(name: name, path: path, isOnline: isOnline));
      }
    }

    setState(() {
      _disks.clear();
      _disks.addAll(disks);
    });
  }

  void _showInFinder(String path) {
    Process.run('open', ['-R', path]);
  }

  void _onProjectSelected(Project? project) {
    setState(() {
      _selectedProject = project;
      if (project != null) {
        _loadFilesFromProject(project.id);
      }
    });
  }

  Future<void> _pickDirectory() async {
    final directoryPath = await FilePicker.platform.getDirectoryPath();
    if (directoryPath != null) {
      final name = directoryPath.split('/').last;
      await _addProject(name, directoryPath);
      await _scanDirectory(_selectedProject!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: Column(
            children: [
              ElevatedButton(
                onPressed: _pickDirectory,
                child: const Text('添加项目'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final directoryPath = await FilePicker.platform.getDirectoryPath();
                  if (directoryPath != null) {
                    await _addException(directoryPath);
                  }
                },
                child: const Text('添加例外'),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: _projects.length,
                  itemBuilder: (context, index) {
                    final project = _projects[index];
                    return ListTile(
                      title: Text(project.name),
                      selected: project == _selectedProject,
                      onTap: () => _onProjectSelected(project),
                    );
                  },
                ),
              ),
              const Divider(),
              const Text('挂载的硬盘'),
              Expanded(
                child: ListView.builder(
                  itemCount: _disks.length,
                  itemBuilder: (context, index) {
                    final disk = _disks[index];
                    return ListTile(
                      title: Text(disk.path),
                      subtitle: Text(disk.isOnline ? '在线' : '离线'),
                      onTap: disk.isOnline
                          ? () async {
                              final scan = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('扫描硬盘'),
                                  content: const Text('您想要扫描整个硬盘还是选择文件夹？'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, false),
                                      child: const Text('选择文件夹'),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, true),
                                      child: const Text('扫描整个硬盘'),
                                    ),
                                  ],
                                ),
                              );

                              if (scan == true) {
                                await _scanDirectory(Project(id: 0, name: disk.path, path: disk.path));
                              } else if (scan == false) {
                                final directoryPath = await FilePicker.platform.getDirectoryPath();
                                if (directoryPath != null) {
                                  await _scanDirectory(Project(id: 0, name: directoryPath.split('/').last, path: directoryPath));
                                }
                              }
                            }
                          : null,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 

3,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  decoration: const InputDecoration(
                    labelText: '搜索',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (query) {
                    setState(() {
                      _mediaFiles = _mediaFiles
                          .where((file) => file.name.toLowerCase().contains(query.toLowerCase()))
                          .toList();
                    });
                  },
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: _mediaFiles.length,
                  itemBuilder: (context, index) {
                    final file = _mediaFiles[index];
                    return ListTile(
                      title: Text(file.name),
                      subtitle: Text('${file.size} bytes, ${file.type}, ${file.path}'),
                      onTap: () => _showInFinder(file.path),
                      onLongPress: () {
                        // 实现上下文菜单
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class Project {
  final int id;
  final String name;
  final String path;

  Project({required this.id, required this.name, required this.path});

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'path': path};
  }

  factory Project.fromMap(Map<String, dynamic> map) {
    return Project(
      id: map['id'],
      name: map['name'],
      path: map['path'],
    );
  }
}

class MediaFile {
  final int? id;
  final String name;
  final int size;
  final String type;
  final String path;
  final int projectId;

  MediaFile({
    required this.id,
    required this.name,
    required this.size,
    required this.type,
    required this.path,
    required this.projectId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'size': size,
      'type': type,
      'path': path,
      'project_id': projectId,
    };
  }

  factory MediaFile.fromMap(Map<String, dynamic> map) {
    return MediaFile(
      id: map['id'],
      name: map['name'],
      size: map['size'],
      type: map['type'],
      path: map['path'],
      projectId: map['project_id'],
    );
  }
}

class Disk {
  final String name;
  final String path;
  final bool isOnline;

  Disk({required this.name, required this.path, required this.isOnline});
}