import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/word_provider.dart';
import '../models/quiz_result.dart';
import '../models/word.dart';
import '../widgets/loading_screen.dart';
import '../widgets/app_drawer.dart';

enum QuizMode {
  newWords,
  mistakes,
  reminders,
}

class QuizScreen extends StatefulWidget {
  final QuizMode mode;

  const QuizScreen({
    super.key,
    this.mode = QuizMode.newWords,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentQuestionIndex = 0;
  int _score = 0;
  List<QuizResult> _results = [];
  List<Word> _quizWords = [];
  List<String> _currentOptions = [];

  String get _screenTitle {
    switch (widget.mode) {
      case QuizMode.newWords:
        return 'New Words Quiz';
      case QuizMode.mistakes:
        return 'Practice Mistakes';
      case QuizMode.reminders:
        return 'Review Reminders';
    }
  }

  @override
  void initState() {
    super.initState();
    _initializeQuiz();
  }

  Future<void> _initializeQuiz() async {
    final wordProvider = Provider.of<WordProvider>(context, listen: false);
    setState(() {
      // Select words based on quiz mode
      switch (widget.mode) {
        case QuizMode.newWords:
          _quizWords = List.from(wordProvider.dailyWords);
          break;
        case QuizMode.mistakes:
          _quizWords = List.from(wordProvider.mistakes);
          break;
        case QuizMode.reminders:
          _quizWords = List.from(wordProvider.reminders);
          break;
      }
      _quizWords.shuffle();
      if (_quizWords.isNotEmpty) {
        _generateOptionsForCurrentQuestion();
      }
    });
  }

  void _generateOptionsForCurrentQuestion() {
    if (_currentQuestionIndex >= _quizWords.length) return;
    
    final correctWord = _quizWords[_currentQuestionIndex];
    final otherWords = Word.wordBank
        .where((w) => w.word != correctWord.word)
        .map((w) => w.definition)
        .toList();
    otherWords.shuffle();

    _currentOptions = [correctWord.definition, ...otherWords.take(3)];
    _currentOptions.shuffle();
  }

  void _handleAnswer(String selectedDefinition) {
    if (_currentQuestionIndex >= _quizWords.length) return;

    final currentWord = _quizWords[_currentQuestionIndex];
    final isCorrect = selectedDefinition == currentWord.definition;

    setState(() {
      if (isCorrect) _score++;

      _results.add(QuizResult(
        word: currentWord,
        isCorrect: isCorrect,
      ));

      if (_currentQuestionIndex < _quizWords.length - 1) {
        _currentQuestionIndex++;
        _generateOptionsForCurrentQuestion();
      } else {
        _submitQuiz();
      }
    });
  }

  Future<void> _submitQuiz() async {
    final wordProvider = Provider.of<WordProvider>(context, listen: false);
    await wordProvider.completeQuiz(_results);
    if (mounted) {
      Navigator.of(context).pop(); // Return to previous screen
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WordProvider>(
      builder: (context, wordProvider, child) {
        if (!wordProvider.isInitialized || _quizWords.isEmpty) {
          if (wordProvider.isInitialized) {
            // No words available for this mode
            return Scaffold(
              appBar: AppBar(
                title: Text(_screenTitle),
              ),
              drawer: const AppDrawer(),
              body: Center(
                child: Text(
                  widget.mode == QuizMode.newWords
                      ? 'Great job! You\'ve completed all words for today.'
                      : 'No words available for review in this category.',
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            );
          }
          return const LoadingScreen();
        }

        final currentWord = _quizWords[_currentQuestionIndex];

        return Scaffold(
          appBar: AppBar(
            title: Text(_screenTitle),
          ),
          drawer: const AppDrawer(),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                LinearProgressIndicator(
                  value: (_currentQuestionIndex + 1) / _quizWords.length,
                  backgroundColor: Colors.grey[200],
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                ),
                const SizedBox(height: 24),
                Text(
                  'What does "${currentWord.word}" mean?',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (currentWord.partOfSpeech != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    '[${currentWord.partOfSpeech}]',
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
                const SizedBox(height: 32),
                ..._currentOptions.map((option) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: ElevatedButton(
                        onPressed: () => _handleAnswer(option),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.all(16),
                        ),
                        child: Text(
                          option,
                          style: const TextStyle(fontSize: 18),
                        ),
                      ),
                    ))
                .toList(),
                const SizedBox(height: 16),
                Text(
                  'Score: $_score / ${_currentQuestionIndex + 1}',
                  style: const TextStyle(fontSize: 18),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
