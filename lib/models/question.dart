class Question {
  final String id;
  final String question;
  final List<String> options;
  final int answerIndex;
  final String difficulty;

  Question({
    required this.id,
    required this.question,
    required this.options,
    required this.answerIndex,
    required this.difficulty,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'] as String,
      question: json['question'] as String,
      options: List<String>.from(json['options']),
      answerIndex: json['answerIndex'] as int,
      difficulty: json['difficulty'] as String,
    );
  }
}
