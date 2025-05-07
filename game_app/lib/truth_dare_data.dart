import 'dart:math';
import 'main.dart'; // For AgeGroup enum

// Enum for question type
enum QuestionType { truth, dare }

class TruthDareQuestion {
  final String question;
  final AgeGroup ageGroup;
  final String categoryId;
  final QuestionType type;

  const TruthDareQuestion({
    required this.question,
    required this.ageGroup,
    required this.categoryId,
    required this.type,
  });
}

// Example hardcoded questions (expand as needed)
const List<TruthDareQuestion> truthDareQuestions = [
  // Kids - Funny
  TruthDareQuestion(
    question: 'What is the silliest thing you have ever done?',
    ageGroup: AgeGroup.kids,
    categoryId: 'KIDS_FUNNY',
    type: QuestionType.truth,
  ),
  TruthDareQuestion(
    question: 'Make your funniest face!',
    ageGroup: AgeGroup.kids,
    categoryId: 'KIDS_FUNNY',
    type: QuestionType.dare,
  ),
  // Teens - Friends
  TruthDareQuestion(
    question: 'Who is your best friend and why?',
    ageGroup: AgeGroup.teen,
    categoryId: 'TEENS_FRIENDS',
    type: QuestionType.truth,
  ),
  TruthDareQuestion(
    question: 'Send a funny selfie to your group chat.',
    ageGroup: AgeGroup.teen,
    categoryId: 'TEENS_FRIENDS',
    type: QuestionType.dare,
  ),
  // Adults - Party
  TruthDareQuestion(
    question: 'What is your wildest party story?',
    ageGroup: AgeGroup.adult,
    categoryId: 'ADULTS_PARTY',
    type: QuestionType.truth,
  ),
  TruthDareQuestion(
    question: 'Do a dance for 30 seconds.',
    ageGroup: AgeGroup.adult,
    categoryId: 'ADULTS_PARTY',
    type: QuestionType.dare,
  ),
  // ...add more questions for other categories/age groups...
];

// Function to get a random question based on filters
TruthDareQuestion? getRandomQuestion({
  required QuestionType type,
  required AgeGroup ageGroup,
  required List<String> categoryIds,
}) {
  final filtered = truthDareQuestions.where((q) =>
    q.type == type &&
    q.ageGroup == ageGroup &&
    categoryIds.contains(q.categoryId)
  ).toList();
  if (filtered.isEmpty) return null;
  final rand = Random();
  return filtered[rand.nextInt(filtered.length)];
}
