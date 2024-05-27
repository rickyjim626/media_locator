import 'dart:io';
import '../models/disk.dart';

class DiskService {
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
        disks.add(Disk(name: name, path: path, isOnline: isOnline));
      }
    }
    return disks;
  }
}