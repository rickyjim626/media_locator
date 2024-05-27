class Project {
  final int id;
  final String name;
  final String path;

  Project({required this.id, required this.name, required this.path});

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'path': path};
  }

  factory Project.fromMap(Map<String, dynamic> map) {
    return Project(
      id: map['id'],
      name: map['name'],
      path: map['path'],
    );
  }
}