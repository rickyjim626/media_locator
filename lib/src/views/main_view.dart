import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../controllers/project_controller.dart';
import '../controllers/disk_controller.dart';
import 'project_view.dart';
import 'disk_view.dart';
import '../services/database_service.dart';
import 'log_view.dart';

class MainView extends StatelessWidget {
  final DatabaseService databaseService;

  const MainView({required this.databaseService, super.key});

  @override
  Widget build(BuildContext context) {
    final ProjectController projectController = ProjectController();
    final DiskController diskController = DiskController();

    // 在程序启动时加载已经存在于数据库中的数据
    projectController.loadProjects();
    diskController.loadDisks();

    return Scaffold(
      appBar: AppBar(
        title: const Text('媒体定位器'),
        actions: [
          IconButton(
            icon: const Icon(Icons.view_list),
            onPressed: () {
              // 添加查看扫描日志文件的入口
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LogView()),
              );
            },
          ),
        ],
      ),
      body: Row(
        children: [
          Expanded(
            flex: 1,
            child: Column(
              children: [
                ElevatedButton(
                  onPressed: () async {
                    final directoryPath = await FilePicker.platform.getDirectoryPath();
                    if (directoryPath != null) {
                      final name = directoryPath.split('/').last;
                      await projectController.addProject(name, directoryPath);
                    }
                  },
                  child: const Text('添加项目'),
                ),
                Expanded(
                  child: ProjectView(controller: projectController),
                ),
                const Divider(),
                const Text('挂载的硬盘'),
                Expanded(
                  child: DiskView(controller: diskController),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: '搜索',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (query) {
                      projectController.searchFiles(query);
                    },
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: projectController.mediaFiles.length,
                    itemBuilder: (context, index) {
                      final file = projectController.mediaFiles[index];
                      return GestureDetector(
                        onSecondaryTapDown: (details) {
                          showMenu(
                            context: context,
                            position: RelativeRect.fromLTRB(
                              details.globalPosition.dx,
                              details.globalPosition.dy,
                              details.globalPosition.dx,
                              details.globalPosition.dy,
                            ),
                            items: [
                              PopupMenuItem(
                                child: const Text('将所选文件添加到例外'),
                                onTap: () async {
                                  await projectController.addException(file.path);
                                },
                              ),
                            ],
                          );
                        },
                        child: ListTile(
                          title: Text(file.name),
                          subtitle: Text('${file.size} bytes, ${file.type}, ${file.path}'),
                          onTap: () => projectController.showInFinder(file.path),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}