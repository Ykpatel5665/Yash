import 'package:flutter/material.dart';

class Player {
  String name;
  Color color;
  Player({required this.name, required this.color});

  // For saving/loading from SharedPreferences
  Map<String, dynamic> toJson() => {'name': name, 'color': color.value};
  static Player fromJson(Map<String, dynamic> json) => Player(
        name: json['name'],
        color: Color(json['color']),
      );
}
