class Evaluation {
  final String id;
  final String courseId;
  final String title;
  final String? description;
  final double weight;
  final double score;
  final int difficulty; // 1 to 5
  final DateTime date;
  final DateTime createdAt;

  Evaluation({
    required this.id,
    required this.courseId,
    required this.title,
    this.description,
    this.weight = 0,
    this.score = 0,
    this.difficulty = 3,
    required this.date,
    required this.createdAt,
  });

  factory Evaluation.fromMap(Map<String, dynamic> map) {
    return Evaluation(
      id: map['id'],
      courseId: map['course_id'],
      title: map['title'],
      description: map['description'],
      weight: (map['weight'] ?? 0).toDouble(),
      score: (map['score'] ?? 0).toDouble(),
      difficulty: map['difficulty'] ?? 3,
      date: DateTime.parse(map['evaluation_date'] ?? map['date']),
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'course_id': courseId,
      'title': title,
      'description': description,
      'weight': weight,
      'score': score,
      'difficulty': difficulty,
      'evaluation_date': date.toIso8601String(),
    };
  }
}
