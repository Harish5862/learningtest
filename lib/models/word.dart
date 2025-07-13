enum WordStatus { new_, mistake, reminder, learned }

class Word {
  final String id;
  final String word;
  final String definition;
  final String example;
  final String partOfSpeech;
  final DateTime dateAdded;
  final DateTime? lastTestedDate;
  final WordStatus status;
  final int correctStreak;
  final bool isNewForToday;

  Word({
    required this.id,
    required this.word,
    required this.definition,
    required this.example,
    required this.partOfSpeech,
    required this.dateAdded,
    this.lastTestedDate,
    this.status = WordStatus.new_,
    this.correctStreak = 0,
    this.isNewForToday = false,
  });

  factory Word.fromJson(Map<String, dynamic> json) {
    return Word(
      id: json['id'] as String,
      word: json['word'] as String,
      definition: json['definition'] as String,
      example: json['example'] as String,
      partOfSpeech: json['partOfSpeech'] as String? ?? 'noun',
      dateAdded: DateTime.parse(json['dateAdded'] as String),
      lastTestedDate: json['lastTestedDate'] != null
          ? DateTime.parse(json['lastTestedDate'] as String)
          : null,
      status: WordStatus.values.firstWhere(
        (e) => e.toString() == 'WordStatus.${json['status'] ?? 'new_'}',
        orElse: () => WordStatus.new_,
      ),
      correctStreak: json['correctStreak'] as int? ?? 0,
      isNewForToday: json['isNewForToday'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'word': word,
      'definition': definition,
      'example': example,
      'dateAdded': dateAdded.toIso8601String(),
      'lastTestedDate': lastTestedDate?.toIso8601String(),
      'partOfSpeech': partOfSpeech,
      'status': status.toString().split('.').last,
      'correctStreak': correctStreak,
      'isNewForToday': isNewForToday,
    };
  }

  Word copyWith({
    String? id,
    String? word,
    String? definition,
    String? example,
    String? partOfSpeech,
    DateTime? dateAdded,
    DateTime? lastTestedDate,
    WordStatus? status,
    int? correctStreak,
    bool? isNewForToday,
  }) {
    return Word(
      id: id ?? this.id,
      word: word ?? this.word,
      definition: definition ?? this.definition,
      example: example ?? this.example,
      partOfSpeech: partOfSpeech ?? this.partOfSpeech,
      dateAdded: dateAdded ?? this.dateAdded,
      lastTestedDate: lastTestedDate ?? this.lastTestedDate,
      status: status ?? this.status,
      correctStreak: correctStreak ?? this.correctStreak,
      isNewForToday: isNewForToday ?? this.isNewForToday,
    );
  }

  // Add word bank for demo purposes
  static final List<Word> wordBank = [
    Word(
      id: '1',
      word: 'Ephemeral',
      definition: 'Lasting for a very short time.',
      example: 'The beauty of cherry blossoms is ephemeral.',
      partOfSpeech: 'adjective',
      dateAdded: DateTime.now(),
      isNewForToday: true,
    ),
    Word(
      id: '2',
      word: 'Ubiquitous',
      definition: 'Present, appearing, or found everywhere.',
      example: 'Smartphones have become ubiquitous in modern society.',
      partOfSpeech: 'adjective',
      dateAdded: DateTime.now(),
      isNewForToday: true,
    ),
    Word(
      id: '3',
      word: 'Mellifluous',
      definition: 'Sweet or musical; pleasant to hear.',
      example: 'Her mellifluous voice captivated the audience.',
      partOfSpeech: 'adjective',
      dateAdded: DateTime.now(),
      isNewForToday: true,
    ),
    Word(
      id: '4',
      word: 'Serendipity',
      definition: 'The occurrence of events by chance in a happy or beneficial way.',
      example: 'Finding this cafe was pure serendipity.',
      partOfSpeech: 'noun',
      dateAdded: DateTime.now(),
      isNewForToday: true,
    ),
    Word(
      id: '5',
      word: 'Ethereal',
      definition: 'Extremely delicate and light in a way that seems not of this world.',
      example: 'The morning mist gave the landscape an ethereal beauty.',
      partOfSpeech: 'adjective',
      dateAdded: DateTime.now(),
      isNewForToday: true,
    ),
  ];
}
