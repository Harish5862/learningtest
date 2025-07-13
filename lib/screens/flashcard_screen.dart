import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/word_provider.dart';
import '../models/word.dart';
import '../widgets/loading_screen.dart';
import '../widgets/app_drawer.dart';

class FlashcardScreen extends StatefulWidget {
  const FlashcardScreen({super.key});

  @override
  State<FlashcardScreen> createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends State<FlashcardScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _flipAnimation;
  bool _isFlipped = false;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _flipAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _flipCard() {
    if (_isFlipped) {
      _animationController.reverse();
    } else {
      _animationController.forward();
    }
    setState(() {
      _isFlipped = !_isFlipped;
    });
  }

  void _nextCard(WordProvider provider) {
    if (_currentIndex >= provider.dailyWords.length - 1) return;
    
    setState(() {
      _currentIndex++;
      if (_isFlipped) {
        _flipCard();
      }
    });
  }

  void _previousCard(WordProvider provider) {
    if (_currentIndex <= 0) return;
    
    setState(() {
      _currentIndex--;
      if (_isFlipped) {
        _flipCard();
      }
    });
  }

  void _markWord(Word word, WordStatus status, WordProvider provider) {
    provider.updateWordStatus(word, status);
    if (_currentIndex < provider.dailyWords.length - 1) {
      _nextCard(provider);
    }
  }

  Widget _buildFrontCard(Word word) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          word.word,
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        if (word.partOfSpeech != null) ...[
          const SizedBox(height: 16),
          Text(
            '[${word.partOfSpeech}]',
            style: const TextStyle(
              fontSize: 18,
              color: Colors.grey,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ],
        const SizedBox(height: 24),
        const Text(
          'Tap to reveal definition',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildBackCard(Word word) {
    return Transform(
      transform: Matrix4.identity()..rotateY(3.14),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            word.definition,
            style: const TextStyle(fontSize: 24),
            textAlign: TextAlign.center,
          ),
          if (word.example != null) ...[
            const SizedBox(height: 24),
            const Text(
              'Example:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              word.example!,
              style: const TextStyle(
                fontSize: 18,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WordProvider>(
      builder: (context, wordProvider, child) {
        if (!wordProvider.isInitialized) {
          return const LoadingScreen();
        }

        final words = wordProvider.dailyWords;
        if (words.isEmpty) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Daily Flashcards'),
            ),
            drawer: const AppDrawer(),
            body: const Center(
              child: Text(
                'Great job! You\'ve completed all words for today.',
                style: TextStyle(fontSize: 18),
              ),
            ),
          );
        }

        // Ensure current index is within bounds
        if (_currentIndex >= words.length) {
          _currentIndex = words.length - 1;
        }

        final currentWord = words[_currentIndex];
        final progress = (_currentIndex + 1) / words.length;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Daily Flashcards'),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(2.0),
              child: LinearProgressIndicator(value: progress),
            ),
          ),
          drawer: const AppDrawer(),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Text(
                      'Word ${_currentIndex + 1} of ${words.length}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: GestureDetector(
                        onTap: _flipCard,
                        child: AnimatedBuilder(
                          animation: _flipAnimation,
                          builder: (context, child) {
                            final transform = Matrix4.identity()
                              ..setEntry(3, 2, 0.001)
                              ..rotateY(_flipAnimation.value * 3.14);
                            return Transform(
                              transform: transform,
                              alignment: Alignment.center,
                              child: Card(
                                elevation: 8,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(24.0),
                                  child: _flipAnimation.value < 0.5
                                      ? _buildFrontCard(currentWord)
                                      : _buildBackCard(currentWord),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: _currentIndex > 0
                            ? () => _previousCard(wordProvider)
                            : null,
                      ),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.refresh, color: Colors.orange),
                        label: const Text('Remind Later'),
                        onPressed: () => _markWord(
                          currentWord,
                          WordStatus.reminder,
                          wordProvider,
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange[100],
                          foregroundColor: Colors.orange[900],
                        ),
                      ),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.check, color: Colors.green),
                        label: const Text('I Know This'),
                        onPressed: () => _markWord(
                          currentWord,
                          WordStatus.learned,
                          wordProvider,
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[100],
                          foregroundColor: Colors.green[900],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.arrow_forward),
                        onPressed: _currentIndex < words.length - 1
                            ? () => _nextCard(wordProvider)
                            : null,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
