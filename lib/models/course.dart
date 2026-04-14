class Course {
  final String id;
  final String userId;
  final String name;
  final String importance;
  final String colorHex;
  final int iconCode;
  final DateTime createdAt;

  Course({
    required this.id,
    required this.userId,
    required this.name,
    required this.importance,
    this.colorHex = '#6C63FF',
    this.iconCode = 58713, // Icons.book_rounded
    required this.createdAt,
  });

  factory Course.fromMap(Map<String, dynamic> map) {
    return Course(
      id: map['id'],
      userId: map['user_id'],
      name: map['name'],
      importance: map['importance'],
      colorHex: map['color_hex'] ?? '#6C63FF',
      iconCode: map['icon_code'] ?? 58713,
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'importance': importance,
      'user_id': userId,
      'color_hex': colorHex,
      'icon_code': iconCode,
    };
  }
}
