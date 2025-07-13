import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'screens/flashcard_screen.dart';
import 'screens/quiz_screen.dart';
import 'screens/progress_screen.dart';
import 'providers/word_provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => WordProvider(),
      child: const VocabBoosterApp(),
    ),
  );
}

class VocabBoosterApp extends StatelessWidget {
  const VocabBoosterApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize the WordProvider
    Future.microtask(() {
      context.read<WordProvider>().initialize();
    });

    return MaterialApp(
      title: 'Daily Vocab Booster',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/flashcards': (context) => const FlashcardScreen(),
        '/quiz': (context) => const QuizScreen(),
        '/progress': (context) => const ProgressScreen(),
      },
      builder: (context, child) {
        return Column(
          children: [
            Expanded(
              child: child ?? const SizedBox(),
            ),
          ],
        );
      },
      onUnknownRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => Scaffold(
            body: Center(
              child: Text('Route ${settings.name} not found'),
            ),
          ),
        );
      },
    );
  }
}
