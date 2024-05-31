import 'dart:io'; // 添加这个导入
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import '../models/project.dart';
import '../models/media_file.dart';
import '../services/database_service.dart';

class ProjectController with ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService(); // 使用全局实例
  final Logger _logger = Logger();
  List<Project> _projects = [];
  List<MediaFile> _mediaFiles = [];

  List<Project> get projects => _projects;
  List<MediaFile> get mediaFiles => _mediaFiles;

  Future<void> loadProjects() async {
    _projects = await _databaseService.loadProjects();
    _logger.i("Loaded projects: ${_projects.length}");
    notifyListeners();
  }

  Future<void> addProject(String name, String path) async {
    try {
      _logger.i('Adding project: $name, $path');  // 使用 Logger 记录信息
      final int id = DateTime.now().millisecondsSinceEpoch;  // 确保 id 非空
      final project = Project(id: id, name: name, path: path);  // 使用时间戳作为临时ID
      await _databaseService.addProject(project);
      await loadProjects();
      await _scanFilesInDirectory(id, path);  // 扫描文件夹内的文件
      _logger.i('Project added and files scanned: $name, $path');  // 使用 Logger 记录信息
    } catch (e) {
      _logger.e('Error adding project: $e');  // 使用 Logger 记录错误
    }
  }

  Future<void> addException(String path) async {
    try {
      await _databaseService.addException(path);
      _logger.i('Exception added for path: $path');  // 使用 Logger 记录信息
    } catch (e) {
      _logger.e('Error adding exception: $e');  // 使用 Logger 记录错误
    }
  }

  Future<void> loadFilesFromProject(int projectId) async {
    _mediaFiles = await _databaseService.loadFilesFromProject(projectId);
    _logger.i("Loaded media files for project $projectId: ${_mediaFiles.length}");
    notifyListeners();
  }

  Future<void> searchFiles(String query) async {
    _logger.i('Searching for files with query: $query');  // 使用 Logger 记录信息
    _mediaFiles = _mediaFiles.where((file) => file.name.toLowerCase().contains(query.toLowerCase())).toList();
    notifyListeners();
  }

  Future<void> showInFinder(String path) async {
    _logger.i('Opening Finder for $path');
    try {
      await Process.run('open', ['-R', path]); // 使用 Process
      _logger.i('Opened Finder for: $path');  // 使用 Logger 记录信息
    } catch (e) {
      _logger.e('Error opening Finder for $path: $e');  // 使用 Logger 记录错误
    }
  }

  Future<void> _scanFilesInDirectory(int projectId, String path) async {
    try {
      final dir = Directory(path);
      final List<MediaFile> files = [];
      await for (var entity in dir.list(recursive: true, followLinks: false)) {
        if (entity is File) {
          final fileStats = await entity.stat();
          final int fileId = DateTime.now().millisecondsSinceEpoch;  // 确保 id 非空
          files.add(MediaFile(
            id: fileId, // 使用时间戳作为临时ID
            projectId: projectId,
            name: entity.path.split('/').last,
            size: fileStats.size,
            type: entity.path.split('.').last,
            path: entity.path,
          ));
        }
      }
      _mediaFiles = files;
      notifyListeners();
      _logger.i('Scanned ${files.length} files in directory: $path');  // 使用 Logger 记录信息
    } catch (e) {
      _logger.e('Error scanning files in directory: $e');  // 使用 Logger 记录错误
    }
  }
}