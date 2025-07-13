import '../models/word.dart';
import '../models/quiz_result.dart';

class VocabService {
  // In-memory storage for demo
  static final Map<WordStatus, List<Word>> _wordLists = {
    WordStatus.new_: [],
    WordStatus.mistake: [],
    WordStatus.reminder: [],
    WordStatus.learned: [],
  };
  static DateTime? _lastLogin;
  static int _streak = 0;

  Future<bool> checkNeedsNewWords() async {
    if (_lastLogin == null) {
      return true;
    }

    final today = DateTime.now();
    return _lastLogin!.day != today.day ||
        _lastLogin!.month != today.month ||
        _lastLogin!.year != today.year;
  }

  Future<void> addNewWordsForToday() async {
    final now = DateTime.now();
    _lastLogin = now;
    
    // Filter word bank to exclude existing words
    final existingWords = _wordLists.values
        .expand((list) => list)
        .map((w) => w.word)
        .toSet();

    final availableWords = Word.wordBank
        .where((w) => !existingWords.contains(w.word))
        .toList()
      ..shuffle();

    // Add 5 new words
    final newWords = availableWords.take(5).map((w) => w.copyWith(
      isNewForToday: true,
      dateAdded: now,
    )).toList();
    
    _wordLists[WordStatus.new_]?.addAll(newWords);
  }

  Future<Map<WordStatus, List<Word>>> getAllWordLists() async {
    return Map.from(_wordLists);
  }

  Future<void> updateWordStatus(String wordId, WordStatus newStatus) async {
    // Find the word in any list
    Word? word;
    WordStatus? oldStatus;

    for (final entry in _wordLists.entries) {
      final index = entry.value.indexWhere((w) => w.id == wordId);
      if (index != -1) {
        word = entry.value[index];
        oldStatus = entry.key;
        break;
      }
    }

    if (word != null && oldStatus != null) {
      // Remove from old list
      _wordLists[oldStatus]?.removeWhere((w) => w.id == wordId);

      // Add to new list with updated status
      final updatedWord = word.copyWith(
        status: newStatus,
        lastTestedDate: DateTime.now(),
      );
      _wordLists[newStatus]?.add(updatedWord);
    }
  }

  Future<int> getStreak() async {
    return _streak;
  }

  Future<void> updateWord(Word word) async {
    // Remove from old list
    for (final list in _wordLists.values) {
      list.removeWhere((w) => w.id == word.id);
    }

    // Add to new list
    _wordLists[word.status]?.add(word);

    // Update streak if the word was marked as learned
    if (word.status == WordStatus.learned) {
      _streak++;
    }
  }

  Future<void> _updateStreak(int correct) async {
    if (correct > 0) {
      _streak++;
    }
  }

  Future<List<List<Word>>> getWordListsForQuiz() async {
    return _wordLists.values.toList();
  }

  Future<void> updateWordsAfterQuiz(List<QuizResult> results) async {
    for (final result in results) {
      final word = result.word;
      WordStatus newStatus;
      
      if (result.isCorrect) {
        // Progress the word status
        switch (word.status) {
          case WordStatus.new_:
            newStatus = WordStatus.reminder;
            break;
          case WordStatus.mistake:
            newStatus = WordStatus.reminder;
            break;
          case WordStatus.reminder:
            newStatus = WordStatus.learned;
            break;
          case WordStatus.learned:
            newStatus = WordStatus.learned; // Stay learned
            break;
        }
      } else {
        // On mistake, move to mistake list unless already there
        newStatus = word.status == WordStatus.mistake 
            ? WordStatus.mistake  // Stay in mistake
            : WordStatus.mistake; // Move to mistake
      }
      
      await updateWordStatus(word.id, newStatus);
    }

    // Update streak based on quiz performance
    final correctCount = results.where((r) => r.isCorrect).length;
    await _updateStreak(correctCount);
  }
}
