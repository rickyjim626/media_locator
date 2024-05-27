import 'package:flutter/material.dart';
import '../controllers/project_controller.dart';

class ProjectView extends StatelessWidget {
  final ProjectController controller;

  const ProjectView({required this.controller, super.key}); // 使用 super 参数

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: controller.projects.length,
      itemBuilder: (context, index) {
        final project = controller.projects[index];
        return ListTile(
          title: Text(project.name),
          subtitle: Text(project.path),
          onTap: () {
            // Handle project selection
          },
        );
      },
    );
  }
}