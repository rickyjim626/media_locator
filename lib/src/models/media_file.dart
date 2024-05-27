class MediaFile {
  final int? id;
  final String name;
  final int size;
  final String type;
  final String path;
  final int projectId;

  MediaFile({
    required this.id,
    required this.name,
    required this.size,
    required this.type,
    required this.path,
    required this.projectId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'size': size,
      'type': type,
      'path': path,
      'project_id': projectId,
    };
  }

  factory MediaFile.fromMap(Map<String, dynamic> map) {
    return MediaFile(
      id: map['id'],
      name: map['name'],
      size: map['size'],
      type: map['type'],
      path: map['path'],
      projectId: map['project_id'],
    );
  }
}