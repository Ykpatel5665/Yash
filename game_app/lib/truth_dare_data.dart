
import 'services/question_db_service.dart';

class Question {
  final String text;
  final String category;
  final String ageGroup;
  final String type;
  final String language;

  Question({
    required this.text,
    required this.category,
    required this.ageGroup,
    required this.type,
    required this.language,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      text: json['text'] ?? '',
      category: json['category'] ?? '',
      ageGroup: json['age_group'] ?? '',
      type: json['type'] ?? '',
      language: json['language'] ?? 'en',
    );
  }
}


Future<List<Question>> loadQuestions({
  required String type, // 'truth' or 'dare'
  required List<String> selectedCategories,
  required String ageGroup, // 'Kids', 'Teens', or 'Adults'
  required String language,
}) async {
  final dbService = QuestionDbService();
  // Only get questions from DB, never fetch from API here
  List<Question> dbQuestions = await dbService.getQuestions(
    type: type,
    selectedCategories: selectedCategories,
    ageGroup: ageGroup,
    language: language,
  );
  print('[DEBUG] Questions from DB: ${dbQuestions.length}');
  return dbQuestions;
}
