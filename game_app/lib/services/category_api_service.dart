import 'package:http/http.dart' as http;
import '../models/category_model.dart';

class CategoryApiService {
  static const String apiUrl = 'https://api.therisingtechie.com/api/categories';
  static const String authToken = 'sk-trkY_9f8e7d6c5b4a1e2f3g4h5i6j7k8l9m0';

  static Future<List<CategoryModel>> fetchCategories() async {
    final response = await http.get(
      Uri.parse(apiUrl),
      headers: {
        'Authorization': '$authToken',
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      return CategoryModel.listFromJson(response.body);
    } else {
      throw Exception('Failed to load categories: \\${response.statusCode}');
    }
  }
}
