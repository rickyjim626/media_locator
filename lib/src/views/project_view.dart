import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';  // 添加这个导入
import '../controllers/project_controller.dart';

class ProjectView extends StatelessWidget {
  final ProjectController controller;

  const ProjectView({required this.controller, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () async {
            final directoryPath = await FilePicker.platform.getDirectoryPath();
            if (directoryPath != null) {
              final name = directoryPath.split('/').last;
              await controller.addProject(name, directoryPath);
            }
          },
          child: const Text('添加项目'),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: controller.projects.length,
            itemBuilder: (context, index) {
              final project = controller.projects[index];
              return ListTile(
                title: Text(project.name),
                selected: controller.projects[index] == project,
                onTap: () => controller.loadFilesFromProject(project.id),
              );
            },
          ),
        ),
      ],
    );
  }
}