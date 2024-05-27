import 'package:flutter/material.dart';
import '../models/disk.dart';
import '../services/disk_service.dart';

class DiskController with ChangeNotifier {
  final DiskService _diskService = DiskService();
  List<Disk> _disks = [];

  List<Disk> get disks => _disks;

  Future<void> loadDisks() async {
    _disks = await _diskService.loadDisks();
    notifyListeners();
  }
}