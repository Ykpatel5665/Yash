
import 'services/question_db_service.dart';
import 'services/question_api_service.dart';

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
  // Try to get questions from DB
  List<Question> dbQuestions = await dbService.getQuestions(
    type: type,
    selectedCategories: selectedCategories,
    ageGroup: ageGroup,
    language: language,
  );
  print('[DEBUG] Questions from DB: ${dbQuestions.length}');
  if (dbQuestions.isNotEmpty) {
    return dbQuestions;
  }
  // If not found, fetch from API for each category
  List<Question> allFetched = [];
  for (final category in selectedCategories) {
    final apiQuestions = await QuestionApiService.fetchQuestions(
      ageGroup: ageGroup.toLowerCase(),
      category: category,
      language: language,
      type: type,
    );
    // Filter by type in case API returns all types
    final filtered = apiQuestions.where((q) => q.type.toLowerCase() == type.toLowerCase()).toList();
    print('[DEBUG] Questions fetched from API for category "$category": ${apiQuestions.length}, filtered by type "$type": ${filtered.length}');
    allFetched.addAll(filtered);
  }
  if (allFetched.isNotEmpty) {
    await dbService.insertQuestions(allFetched);
    // Return random order from DB (now inserted)
    return await dbService.getQuestions(
      type: type,
      selectedCategories: selectedCategories,
      ageGroup: ageGroup,
      language: language,
    );
  }
  return [];
}
