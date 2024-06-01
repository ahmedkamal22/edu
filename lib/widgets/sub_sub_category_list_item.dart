import 'package:academy_app/screens/courses_screen.dart';
import 'package:flutter/material.dart';

import '../constants.dart';

class SubSubCategoryListItem extends StatelessWidget {
  final int? id;
  final int? subCatId;
  final int? parent;
  final String? name;
  final int? numberOfCourses;
  final int? index;

  const SubSubCategoryListItem(
      {Key? key,
      @required this.id,
      @required this.subCatId,
      @required this.parent,
      @required this.name,
      @required this.numberOfCourses,
      @required this.index})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).pushNamed(
          CoursesScreen.routeName,
          arguments: {
            'category_id': id,
            'sub_category_id': subCatId,
            'seacrh_query': null,
            'type': CoursesPageData.Category,
          },
        );
      },
      child: Card(
        // color: backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        elevation: 0,
        child: Row(
          // mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 15.0, right: 15.0),
              child: Text(
                "${index! + 1}.",
              ),
            ),
            Text(
              name.toString(),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                color: iCardColor,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10.0, vertical: 2),
                  child: ImageIcon(
                    const AssetImage("assets/images/long_arrow_right.png"),
                    color: kPrimaryColor.withOpacity(0.7),
                    size: 40,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
