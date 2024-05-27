import 'package:flutter/material.dart';
import '../models/project.dart';
import '../models/media_file.dart';
import '../services/database_service.dart';

class ProjectController with ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  List<Project> _projects = [];
  List<MediaFile> _mediaFiles = [];

  List<Project> get projects => _projects;
  List<MediaFile> get mediaFiles => _mediaFiles;

  Future<void> loadProjects() async {
    _projects = await _databaseService.loadProjects();
    notifyListeners();
  }

  Future<void> addProject() async {
    // implement add project logic
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
    await Process.run('open', ['-R', path]);
  }
}