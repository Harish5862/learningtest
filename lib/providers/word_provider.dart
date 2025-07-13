import 'package:flutter/foundation.dart';
import '../models/word.dart';
import '../models/quiz_result.dart';
import '../services/vocab_service.dart';

class WordProvider with ChangeNotifier {
  final VocabService _wordService = VocabService();
  Map<WordStatus, List<Word>> _wordLists = {
    WordStatus.new_: [],
    WordStatus.mistake: [],
    WordStatus.reminder: [],
    WordStatus.learned: [],
  };
  bool _isLoading = false;
  bool _isInitialized = false;
  int _streak = 0;

  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;
  List<Word> get dailyWords => _wordLists[WordStatus.new_] ?? [];
  List<Word> get mistakes => _wordLists[WordStatus.mistake] ?? [];
  List<Word> get reminders => _wordLists[WordStatus.reminder] ?? [];
  List<Word> get learntWords => _wordLists[WordStatus.learned] ?? [];
  int get streak => _streak;

  Future<void> initialize() async {
    if (_isInitialized) return;
    _isLoading = true;
    notifyListeners();

    try {
      // Check if we need to add new words for today
      final needsNewWords = await _wordService.checkNeedsNewWords();
      if (needsNewWords) {
        await _wordService.addNewWordsForToday();
      }

      // Load all word lists
      await _loadAllWordLists();
      _streak = await _wordService.getStreak();
      _isInitialized = true;
    } catch (e) {
      debugPrint('Error initializing word provider: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateWordStatus(Word word, WordStatus newStatus) async {
    try {
      await _wordService.updateWordStatus(word.id, newStatus);
      await _loadAllWordLists();
    } catch (e) {
      debugPrint('Error updating word status: $e');
    }
  }

  Future<void> _loadAllWordLists() async {
    try {
      _wordLists = await _wordService.getAllWordLists();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading word lists: $e');
    }
  }

  Future<void> updateWordAfterReview({
    required Word word,
    required bool isCorrect,
    WordStatus? newStatus,
  }) async {
    try {
      final now = DateTime.now();
      WordStatus status;
      int correctStreak;

      if (isCorrect) {
        if (word.status == WordStatus.new_) {
          status = newStatus ?? WordStatus.reminder;
        } else if (word.status == WordStatus.mistake) {
          correctStreak = word.correctStreak + 1;
          status = correctStreak >= 3 ? WordStatus.learned : WordStatus.mistake;
        } else {
          status = WordStatus.learned;
        }
        correctStreak = word.correctStreak + 1;
      } else {
        status = WordStatus.mistake;
        correctStreak = 0;
      }

      final updatedWord = word.copyWith(
        lastTestedDate: now,
        status: status,
        correctStreak: correctStreak,
      );

      await _wordService.updateWord(updatedWord);
      await _loadAllWordLists(); // Refresh lists after update
    } catch (e) {
      debugPrint('Error updating word after review: $e');
    }
  }

  Future<void> completeQuiz(List<QuizResult> results) async {
    try {
      await _wordService.updateWordsAfterQuiz(results);
      await _loadAllWordLists();
      _streak = await _wordService.getStreak();
      notifyListeners();
    } catch (e) {
      debugPrint('Error completing quiz: $e');
    }
  }
}
