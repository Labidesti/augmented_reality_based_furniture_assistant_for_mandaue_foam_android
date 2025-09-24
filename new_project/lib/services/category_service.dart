import 'dart:convert';
import 'package:flutter/services.dart';

class CategoryService {
  static Future<Map<String, dynamic>> loadCategories() async {
    final String response =
    await rootBundle.loadString('assets/categories.json');
    return json.decode(response);
  }
}
