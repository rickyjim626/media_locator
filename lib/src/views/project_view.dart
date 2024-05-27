import 'package:flutter/material.dart';
import '../controllers/project_controller.dart';
import '../models/project.dart';

class ProjectView extends StatelessWidget {
  final ProjectController controller;

  const ProjectView({required this.controller, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () => controller.addProject(),
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