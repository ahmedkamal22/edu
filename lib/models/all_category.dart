import 'package:flutter/foundation.dart';

class AllCategory {
  final int? id;
  final String? title;
  final String? subCategoryId; //new update
  List<AllSubCategory> subCategory;

  AllCategory(
      {@required this.id,
      @required this.title,
      required this.subCategoryId,
      required this.subCategory});
}

class AllSubCategory {
  final int? id;
  final String? title;
  List<AllSubSubCategories> subSubCategories; //new update
  AllSubCategory({this.id, this.title, required this.subSubCategories});
}

class AllSubSubCategories {
  final int? id;
  final String? title;
  final String? parent;

  AllSubSubCategories({this.id, this.title, this.parent});
} //new update
