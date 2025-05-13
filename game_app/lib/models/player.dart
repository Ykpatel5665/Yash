import 'package:flutter/material.dart';

class Player {
  String name;
  Player({required this.name});

  // For saving/loading from SharedPreferences
  Map<String, dynamic> toJson() => {'name': name};
  static Player fromJson(Map<String, dynamic> json) => Player(
        name: json['name'],
      );
}
