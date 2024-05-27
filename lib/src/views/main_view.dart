import 'package:flutter/material.dart';
import '../controllers/project_controller.dart';
import '../controllers/disk_controller.dart';
import 'project_view.dart';
import 'disk_view.dart';

class MainView extends StatelessWidget {
  const MainView({super.key});

  @override
  Widget build(BuildContext context) {
    final ProjectController projectController = ProjectController();
    final DiskController diskController = DiskController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('媒体定位器'),
      ),
      body: Row(
        children: [
          Expanded(
            flex: 1,
            child: Column(
              children: [
                ElevatedButton(
                  onPressed: () => projectController.addProject(),
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
                      return ListTile(
                        title: Text(file.name),
                        subtitle: Text('${file.size} bytes, ${file.type}, ${file.path}'),
                        onTap: () => projectController.showInFinder(file.path),
                        onLongPress: () {
                          // 实现上下文菜单
                        },
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