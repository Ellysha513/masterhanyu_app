class Lesson {
  final String id;
  final String title;
  final String level;
  final int duration;
  final String category;
  final String description;
  final List<VocabWord> vocab;

  Lesson({
    required this.id,
    required this.title,
    required this.level,
    required this.duration,
    required this.category,
    required this.description,
    required this.vocab,
  });
}

class VocabWord {
  final String hanzi;
  final String pinyin;
  final String meaning;
  VocabWord(this.hanzi, this.pinyin, this.meaning);
}
