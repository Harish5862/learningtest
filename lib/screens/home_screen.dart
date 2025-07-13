import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/word_provider.dart';
import '../widgets/loading_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<WordProvider>(
      builder: (context, wordProvider, child) {
        if (!wordProvider.isInitialized) {
          return const LoadingScreen();
        }

        final today = DateTime.now();
        final dateString = DateFormat('EEEE, MMMM d, y').format(today);

        return Scaffold(
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(dateString),
                  const SizedBox(height: 24),
                  _buildStats(wordProvider),
                  const SizedBox(height: 32),
                  _buildTodayActions(context, wordProvider),
                  const SizedBox(height: 32),
                  _buildQuickReviews(context, wordProvider),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(String dateString) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              dateString,
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            const Text(
              'Welcome Back!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStats(WordProvider provider) {
    return Row(
      children: [
        _buildStatCard(
          icon: const Icon(Icons.star, color: Colors.amber),
          value: provider.learntWords.length.toString(),
          label: 'Learned',
        ),
        const SizedBox(width: 8),
        _buildStatCard(
          icon: const Icon(Icons.error_outline, color: Colors.red),
          value: provider.mistakes.length.toString(),
          label: 'Mistakes',
        ),
        const SizedBox(width: 8),
        _buildStatCard(
          icon: const Icon(Icons.local_fire_department, color: Colors.orange),
          value: '${provider.streak} days',
          label: 'Streak',
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required Icon icon,
    required String value,
    required String label,
  }) {
    return Expanded(
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              icon,
              const SizedBox(height: 8),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTodayActions(BuildContext context, WordProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Today's Actions",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        _buildActionCard(
          icon: const Icon(Icons.book, color: Colors.blue, size: 32),
          title: "Explore Today's ${provider.dailyWords.length} New Words",
          subtitle: 'Learn definitions and examples',
          onTap: () => Navigator.pushNamed(context, '/flashcards'),
          disabled: provider.dailyWords.isEmpty,
          badge: provider.dailyWords.isNotEmpty
              ? '${provider.dailyWords.length} New'
              : 'Done!',
        ),
        const SizedBox(height: 12),
        _buildActionCard(
          icon: const Icon(Icons.psychology, color: Colors.purple, size: 32),
          title: 'Daily Quiz',
          subtitle: '5 new words + 5 from mistakes',
          onTap: () => Navigator.pushNamed(
            context,
            '/quiz',
            arguments: {'type': 'daily'},
          ),
          disabled: provider.dailyWords.isEmpty && provider.mistakes.isEmpty,
        ),
      ],
    );
  }

  Widget _buildQuickReviews(BuildContext context, WordProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Reviews',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        _buildActionCard(
          icon: const Icon(Icons.refresh, color: Colors.red, size: 32),
          title: 'Review Mistakes',
          subtitle: 'Test yourself on ${provider.mistakes.length} words',
          onTap: () => Navigator.pushNamed(
            context,
            '/quiz',
            arguments: {'type': 'mistakes'},
          ),
          disabled: provider.mistakes.isEmpty,
        ),
        const SizedBox(height: 12),
        _buildActionCard(
          icon: const Icon(Icons.timer, color: Colors.orange, size: 32),
          title: "Review 'Remind Me'",
          subtitle: 'Test yourself on ${provider.reminders.length} words',
          onTap: () => Navigator.pushNamed(
            context,
            '/quiz',
            arguments: {'type': 'remind'},
          ),
          disabled: provider.reminders.isEmpty,
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required Icon icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool disabled = false,
    String? badge,
  }) {
    return Opacity(
      opacity: disabled ? 0.5 : 1.0,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          onTap: disabled ? null : onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: icon,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                if (badge != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      badge,
                      style: TextStyle(
                        color: Colors.blue[800],
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
