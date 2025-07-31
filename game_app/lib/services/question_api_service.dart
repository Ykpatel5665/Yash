import 'package:http/http.dart' as http;
import '../truth_dare_data.dart';
import 'dart:convert';

class QuestionApiService {
  static const String apiUrl = 'https://api.therisingtechie.com/api/questions';
  static const String authToken = 'sk-trkY_9f8e7d6c5b4a1e2f3g4h5i6j7k8l9m0';

  static Future<List<Question>> fetchQuestions({
    required String ageGroup,
    required String category,
    required String language,
    required String type,
  }) async {
    final url = '$apiUrl?age_group=$ageGroup&category=${Uri.encodeComponent(category)}&language=$language&type=$type';
    print('[DEBUG] Fetching questions from: $url');
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': authToken,
        'Content-Type': 'application/json',
      },
    );
    print('[DEBUG] API response status: \'${response.statusCode}\' body: ${response.body}');
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      print('[DEBUG] Questions fetched: \'${data.length}\'');
      return data.map((q) => Question.fromJson(q)).toList();
    } else {
      throw Exception('Failed to load questions: ${response.statusCode}');
    }
  }
}
