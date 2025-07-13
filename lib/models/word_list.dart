import 'word.dart';

enum WordListType { newToday, mistakes, remindMeLater, learnt }

class WordList {
  final WordListType type;
  final List<Word> words;

  WordList({required this.type, required this.words});
}
