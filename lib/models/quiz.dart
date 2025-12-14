class QuizQuestion {
  final String question;
  final List<QuizOption> options;
  QuizQuestion(this.question, this.options);
}

class QuizOption {
  final String text;
  final bool correct;
  QuizOption(this.text, this.correct);
}
