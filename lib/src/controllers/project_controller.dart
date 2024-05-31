import 'dart:io'; 
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import '../models/project.dart';
import '../models/media_file.dart';
import '../services/database_service.dart';

class ProjectController with ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  final Logger _logger = Logger();
  List<Project> _projects = [];
  List<MediaFile> _mediaFiles = [];

  List<Project> get projects => _projects;
  List<MediaFile> get mediaFiles => _mediaFiles;

  Future<void> loadProjects() async {
    _projects = await _databaseService.loadProjects();
    notifyListeners();
  }

  Future<void> addProject(String name, String path) async {
    try {
      _logger.i('Adding project: $name, $path');
      final int id = DateTime.now().millisecondsSinceEpoch;
      final project = Project(id: id, name: name, path: path);
      await _databaseService.addProject(project);
      await loadProjects();
      await _scanFilesInDirectory(id, path);
      _logger.i('Project added and files scanned: $name, $path');
    } catch (e) {
      _logger.e('Error adding project: $e');
    }
  }

  Future<void> addException(String path) async {
    try {
      await _databaseService.addException(path);
      _logger.i('Exception added for path: $path');
    } catch (e) {
      _logger.e('Error adding exception: $e');
    }
  }

  Future<void> loadFilesFromProject(int projectId) async {
    _mediaFiles = await _databaseService.loadFilesFromProject(projectId);
    notifyListeners();
  }

  Future<void> searchFiles(String query) async {
    _logger.i('Searching for files with query: $query');
    _mediaFiles = _mediaFiles.where((file) => file.name.toLowerCase().contains(query.toLowerCase())).toList();
    notifyListeners();
  }

  Future<void> showInFinder(String path) async {
    _logger.i('Opening Finder for $path');
    try {
      await Process.run('open', ['-R', path]);
      _logger.i('Opened Finder for: $path');
    } catch (e) {
      _logger.e('Error opening Finder for $path: $e');
    }
  }

  Future<void> _scanFilesInDirectory(int projectId, String path) async {
    try {
      final dir = Directory(path);
      final List<MediaFile> files = [];
      await for (var entity in dir.list(recursive: true, followLinks: false)) {
        if (entity is File) {
          final fileStats = await entity.stat();
          final int fileId = DateTime.now().millisecondsSinceEpoch;
          files.add(MediaFile(
            id: fileId,
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
      _logger.i('Scanned ${files.length} files in directory: $path');
    } catch (e) {
      _logger.e('Error scanning files in directory: $e');
    }
  }
}