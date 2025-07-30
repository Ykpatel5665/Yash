import 'dart:convert';

class CategoryModel {
  final String key;
  final String ageGroup;
  final String emoji;
  final Map<String, String> labels;

  CategoryModel({
    required this.key,
    required this.ageGroup,
    required this.emoji,
    required this.labels,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      key: json['key'] as String,
      ageGroup: json['age_group'] as String,
      emoji: json['emoji'] as String,
      labels: Map<String, String>.from(json['labels'] as Map),
    );
  }

  Map<String, dynamic> toJson() => {
        'key': key,
        'age_group': ageGroup,
        'emoji': emoji,
        'labels': labels,
      };

  static List<CategoryModel> listFromJson(String str) {
    final data = json.decode(str) as List;
    return data.map((e) => CategoryModel.fromJson(e)).toList();
  }
}
