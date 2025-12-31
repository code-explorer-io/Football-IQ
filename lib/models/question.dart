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

  /// Safely parse JSON with null checks and type validation
  /// Throws FormatException if required fields are missing or invalid
  factory Question.fromJson(Map<String, dynamic> json) {
    // Validate required fields exist
    if (json['id'] == null) {
      throw FormatException('Question missing required field: id');
    }
    if (json['question'] == null) {
      throw FormatException('Question missing required field: question');
    }
    if (json['options'] == null) {
      throw FormatException('Question missing required field: options');
    }
    if (json['answerIndex'] == null) {
      throw FormatException('Question missing required field: answerIndex');
    }

    // Validate types
    final id = json['id'];
    if (id is! String) {
      throw FormatException('Question id must be a string, got: ${id.runtimeType}');
    }

    final question = json['question'];
    if (question is! String) {
      throw FormatException('Question question must be a string, got: ${question.runtimeType}');
    }

    final optionsRaw = json['options'];
    if (optionsRaw is! List) {
      throw FormatException('Question options must be a list, got: ${optionsRaw.runtimeType}');
    }

    // Validate all options are strings
    final options = <String>[];
    for (int i = 0; i < optionsRaw.length; i++) {
      final option = optionsRaw[i];
      if (option is! String) {
        throw FormatException('Question option[$i] must be a string, got: ${option.runtimeType}');
      }
      options.add(option);
    }

    if (options.length < 2) {
      throw FormatException('Question must have at least 2 options, got: ${options.length}');
    }

    final answerIndex = json['answerIndex'];
    if (answerIndex is! int) {
      throw FormatException('Question answerIndex must be an int, got: ${answerIndex.runtimeType}');
    }

    if (answerIndex < 0 || answerIndex >= options.length) {
      throw FormatException('Question answerIndex $answerIndex out of range [0, ${options.length - 1}]');
    }

    // Difficulty is optional, default to 'medium'
    final difficulty = json['difficulty'] as String? ?? 'medium';

    return Question(
      id: id,
      question: question,
      options: options,
      answerIndex: answerIndex,
      difficulty: difficulty,
    );
  }
}
