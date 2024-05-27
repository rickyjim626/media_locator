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
    notifyListeners();
  }

  Future<void> addProject(String name, String path) async {
    final project = Project(id: 0, name: name, path: path);  // id 需要从数据库生成
    await _databaseService.addProject(project);
    await loadProjects();
  }

  Future<void> addException(String path) async {
    await _databaseService.addException(path);
  }

  Future<void> loadFilesFromProject(int projectId) async {
    _mediaFiles = await _databaseService.loadFilesFromProject(projectId);
    notifyListeners();
  }

  Future<void> searchFiles(String query) async {
    _mediaFiles = _mediaFiles.where((file) => file.name.toLowerCase().contains(query.toLowerCase())).toList();
    notifyListeners();
  }

  Future<void> showInFinder(String path) async {
    _logger.i('Opening Finder for $path');
    await Process.run('open', ['-R', path]); // 这里使用了 Process
  }
}