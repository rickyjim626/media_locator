import 'dart:io';
import '../models/disk.dart';
import '../services/database_service.dart';

class DiskService {
  final DatabaseService _databaseService = DatabaseService();

  Future<List<Disk>> loadDisks() async {
    final result = await Process.run('df', ['-h']);
    final lines = result.stdout.toString().split('\n');
    final disks = <Disk>[];

    for (var line in lines.skip(1)) {
      final parts = line.split(RegExp(r'\s+'));
      if (parts.length > 5) {
        final name = parts[0];
        final path = parts[5];
        final isOnline = Directory(path).existsSync();
        final disk = Disk(
          id: 0, // 这里可能需要从数据库中生成ID
          name: name,
          path: path,
          isOnline: isOnline,
          lastChecked: DateTime.now(),
        );
        disks.add(disk);
        await _databaseService.addDisk(disk);
      }
    }
    return disks;
  }
}