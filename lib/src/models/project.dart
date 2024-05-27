class Project {
  int? id;  // id 现在是可选的，因为数据库会自动递增
  String name;
  String path;

  Project({this.id, required this.name, required this.path});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'path': path,
    };
  }

  static Project fromMap(Map<String, dynamic> map) {
    return Project(
      id: map['id'],
      name: map['name'],
      path: map['path'],
    );
  }
}