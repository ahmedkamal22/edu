import 'dart:convert';

import 'package:academy_app/models/all_category.dart';
import 'package:academy_app/models/sub_category.dart';
import 'package:academy_app/models/sub_sub_category.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../constants.dart';
import '../models/category.dart';

class Categories with ChangeNotifier {
  List<Category> _items = [];
  List<SubCategory> _subItems = [];
  List<SubSubCategory> _subSubItems = [];
  List<AllCategory> _allItems = [];

  List<Category> get items {
    return [..._items];
  }

  List<SubCategory> get subItems {
    return [..._subItems];
  }

  List<SubSubCategory> get subSubItems {
    return [..._subSubItems];
  }

  List<AllCategory> get allItems {
    return [..._allItems];
  }

  Future<void> fetchCategories() async {
    var url = '$BASE_URL/api/categories';
    try {
      final response = await http.get(Uri.parse(url));
      final extractedData = json.decode(response.body) as List;
      // ignore: unnecessary_null_comparison
      if (extractedData == null) {
        return;
      }
      // print(extractedData);
      final List<Category> loadedCategories = [];

      for (var catData in extractedData) {
        loadedCategories.add(Category(
          id: int.parse(catData['id']),
          title: catData['name'],
          thumbnail: catData['thumbnail'],
          numberOfCourses: catData['number_of_courses'],
          numberOfSubCategories: catData['number_of_sub_categories'],
        ));

        // print(catData['name']);
      }
      _items = loadedCategories;
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  Future<void> fetchSubCategories(int catId) async {
    var url = '$BASE_URL/api/sub_categories/$catId';
    try {
      final response = await http.get(Uri.parse(url));
      final extractedData = json.decode(response.body) as List;
      // ignore: unnecessary_null_comparison
      if (extractedData == null) {
        return;
      }
      // print(extractedData);
      final List<SubCategory> loadedCategories = [];

      for (var catData in extractedData) {
        loadedCategories.add(SubCategory(
          id: int.parse(catData['id']),
          subId: int.parse(catData['sub_category_id']),
          title: catData['name'],
          parent: int.parse(catData['parent']),
          numberOfCourses: catData['number_of_courses'],
        ));

        // print(catData['name']);
      }
      _subItems = loadedCategories;
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  Future<void> fetchSubSubCategories(int subCatId) async {
    var url = '$BASE_URL/api/sub_sub_categories/$subCatId';
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode != 200) {
        throw Exception('Failed to load data: ${response.statusCode}');
      }

      final extractedData = json.decode(response.body) as List<dynamic>;
      if (extractedData == null) {
        throw Exception('No data received from the server');
      }

      final List<SubSubCategory> loadedSubSubCategories = [];
      for (var catData in extractedData) {
        try {
          loadedSubSubCategories.add(SubSubCategory(
            id: int.parse(catData['id']),
            subId: int.parse(catData['sub_category_id']),
            title: catData['name'] ?? 'No Title',
            parent: int.parse(catData['parent']),
            numberOfCourses: catData['number_of_courses'] is String
                ? int.parse(catData['number_of_courses'])
                : catData['number_of_courses'],
          ));
        } catch (e) {
          print('Error parsing catData: $catData');
          print('Exception: $e');
        }
      }

      _subSubItems = loadedSubSubCategories;
      notifyListeners();
    } catch (error) {
      print('Error fetching sub-sub-categories: $error');
      rethrow;
    }
  }

  Future<void> fetchAllCategory() async {
    var url = '$BASE_URL/api/all_categories'; //new update
    try {
      final response = await http.get(Uri.parse(url));
      final extractedData = json.decode(response.body) as List;
      // print(extractedData);
      // ignore: unnecessary_null_comparison
      if (extractedData == null) {
        return;
      }
      // print(extractedData);
      final List<AllCategory> loadedCategories = [];

      for (var catData in extractedData) {
        loadedCategories.add(AllCategory(
          id: int.parse(catData['id']),
          title: catData['name'],
          subCategoryId: catData['sub_category_id'], //new update
          subCategory:
              buildSubCategory(catData['sub_categories'] as List<dynamic>),
        ));

        // print(catData['name']);
      }
      _allItems = loadedCategories;
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  List<AllSubCategory> buildSubCategory(List extractedSubCategory) {
    final List<AllSubCategory> loadedSubCategories = [];

    for (var subData in extractedSubCategory) {
      loadedSubCategories.add(AllSubCategory(
        id: int.parse(subData['id']),
        title: subData['name'],
        subSubCategories:
            buildSubSubCategory(subData['sub_sub_categories'] as List<dynamic>),
      ));
    }
    // print(loadedLessons.first.title);
    return loadedSubCategories;
  }

  List<AllSubSubCategories> buildSubSubCategory(List extractedSubCategory) {
    final List<AllSubSubCategories> loadedSubCategories = [];

    for (var subSubData in extractedSubCategory) {
      loadedSubCategories.add(AllSubSubCategories(
        id: int.parse(subSubData['id']),
        title: subSubData['name'],
      ));
    }
    // print(loadedLessons.first.title);
    return loadedSubCategories;
  }
}
