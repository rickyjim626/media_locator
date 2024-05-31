class Disk {
  final int id;
  final String name;
  final String path;
  final bool isOnline;
  final DateTime lastChecked;

  Disk({
    required this.id,
    required this.name,
    required this.path,
    required this.isOnline,
    required this.lastChecked,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'path': path,
      'isOnline': isOnline ? 1 : 0,
      'lastChecked': lastChecked.toIso8601String(),
    };
  }

  factory Disk.fromMap(Map<String, dynamic> map) {
    return Disk(
      id: map['id'],
      name: map['name'],
      path: map['path'],
      isOnline: map['isOnline'] == 1,
      lastChecked: DateTime.parse(map['lastChecked']),
    );
  }
}