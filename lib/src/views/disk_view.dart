import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/disk_controller.dart';
import 'package:logger/logger.dart';

class DiskView extends StatelessWidget {
  final Logger _logger = Logger();

  DiskView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DiskController>(
      builder: (context, controller, child) {
        return ListView.builder(
          itemCount: controller.disks.length,
          itemBuilder: (context, index) {
            final disk = controller.disks[index];
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