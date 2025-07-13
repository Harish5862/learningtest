import 'word.dart';

class QuizResult {
  final Word word;
  final bool isCorrect;
  final DateTime timestamp;

  QuizResult({
    required this.word,
    required this.isCorrect,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}
