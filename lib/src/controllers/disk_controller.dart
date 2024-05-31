import 'dart:io';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import '../models/disk.dart';
import '../services/database_service.dart';

class DiskController with ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  final Logger _logger = Logger();
  List<Disk> _disks = [];

  List<Disk> get disks => _disks;

  Future<void> loadDisks() async {
    try {
      _disks = await _databaseService.loadDisks();
      _logger.i('Disks loaded: ${_disks.length}');
      notifyListeners();
    } catch (e) {
      _logger.e('Error loading disks: $e');
    }
  }

  Future<void> updateDiskStatus() async {
    try {
      final List<Disk> disks = await _databaseService.loadDisks();
      for (var disk in disks) {
        final bool isOnline = Directory(disk.path).existsSync();
        final updatedDisk = Disk(
          id: disk.id,
          name: disk.name,
          path: disk.path,
          isOnline: isOnline,
          lastChecked: DateTime.now(),
        );
        await _databaseService.addDisk(updatedDisk);
        _logger.i('Disk status updated: ${disk.name}, mounted: $isOnline');
      }
      await loadDisks();
    } catch (e) {
      _logger.e('Error updating disk status: $e');
    }
  }
}