import 'word.dart';

class WordProgress {
  final Word word;
  int correctOnDifferentDays;
  DateTime? lastAnswered;

  WordProgress({required this.word, this.correctOnDifferentDays = 0, this.lastAnswered});
}

class UserProgress {
  int totalLearnt;
  int mistakesPending;
  int currentStreak;

  UserProgress({this.totalLearnt = 0, this.mistakesPending = 0, this.currentStreak = 0});
}
