import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../controllers/disk_controller.dart';
import 'package:logger/logger.dart';

class DiskView extends StatelessWidget {
  final DiskController controller;
  final Logger _logger = Logger();

  DiskView({required this.controller, super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: ValueNotifier(controller.disks), // 使用实际的 ValueNotifier
      builder: (context, List<Disk> disks, child) {
        return ListView.builder(
          itemCount: disks.length,
          itemBuilder: (context, index) {
            final disk = disks[index];
            _logger.i('Displaying disk: ${disk.name}, online: ${disk.isOnline}');
            return ListTile(
              title: Text(disk.name),
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
                        // 调用controller扫描整个硬盘
                      } else if (scan == false) {
                        final directoryPath = await FilePicker.platform.getDirectoryPath();
                        if (directoryPath != null) {
                          // 调用controller扫描指定文件夹
                        }
                      }
                    }
                  : null,
            );
          },
        );
      },
    );
  }
}