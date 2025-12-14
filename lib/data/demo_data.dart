import '../models/lesson.dart';

final List<Lesson> demoLessons = [
  Lesson(
	id: 'L1',
	title: 'Greetings & Basics',
	level: 'Beginner',
	duration: 8,
	category: 'Vocabulary',
	description: 'Learn how to say hello, introduce yourself, and common greetings.',
	vocab: [VocabWord('你好', 'nǐ hǎo', 'hello'), VocabWord('早上好', 'zǎo shàng hǎo', 'good morning')],
  ),
  Lesson(
	id: 'L2',
	title: 'Numbers & Time',
	level: 'Beginner',
	duration: 10,
	category: 'Grammar',
	description: 'Numbers 1-100, asking for time and dates.',
	vocab: [VocabWord('一', 'yī', 'one'), VocabWord('十', 'shí', 'ten')],
  ),
];
 
 
// final List<QuizQuestion> demoQuiz = [
// QuizQuestion('What does "你好" mean?', [
// QuizOption('Goodbye', false),
// QuizOption('Hello', true),
// QuizOption('Thank you', false),
// ]),
// ];