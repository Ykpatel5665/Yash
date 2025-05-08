import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class Question {
  final String text;
  final String category;
  final String ageGroup;
  final String type;

  Question({required this.text, required this.category, required this.ageGroup, required this.type});

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      text: json['text'],
      category: json['category'],
      ageGroup: json['ageGroup'],
      type: json['type'],
    );
  }
}

Future<List<Question>> loadQuestions({
  required String type, // 'truth' or 'dare'
  required List<String> selectedCategories,
  required String ageGroup, // 'Kids', 'Teens', or 'Adults'
}) async {
  final String data = await rootBundle.loadString('assets/questions.json');
  final List<dynamic> jsonResult = json.decode(data)['questions'];
  return jsonResult
      .map((q) => Question.fromJson(q))
      .where((q) =>
          q.type == type &&
          selectedCategories.contains(q.category) &&
          q.ageGroup == ageGroup)
      .toList();
}
