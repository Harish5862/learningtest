import 'word.dart';

class QuizQuestion {
  final Word word;
  final List<String> options;
  final String correctAnswer;
  String? userAnswer;

  QuizQuestion({
    required this.word,
    required this.options,
    required this.correctAnswer,
    this.userAnswer,
  });
}

class Quiz {
  final List<QuizQuestion> questions;

  Quiz({required this.questions});
}
