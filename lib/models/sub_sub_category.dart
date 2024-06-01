import 'package:flutter/foundation.dart';

class SubSubCategory {
  final int? id;
  final int? subId;
  final String? title;
  final int? parent;
  final int? numberOfCourses;

  SubSubCategory({
    @required this.id,
    @required this.subId,
    @required this.title,
    @required this.parent,
    @required this.numberOfCourses,
  });
}
