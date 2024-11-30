import 'package:flutter/cupertino.dart';

class Lesson {
  int? id;
  int? courseId;
  String? title;
  String? duration;
  String? durationForMobile;
  String? videoUrl;
  String? lessonType;
  String? isFree;
  String? summary;
  String? attachmentType;
  String? attachment;
  String? attachmentUrl;
  String? isCompleted;
  String? videoUrlWeb;
  String? videoUrlMobile;
  String? videoTypeWeb;
  String? videoTypeMobile;
  String? vimeoVideoId;
  String? lessonPrice;
  String? lessonDiscountPrice;
  String? lessonExpiryData;
  bool? isLessonPurchased;

  Lesson(
      {@required this.id,
      @required this.title,
      @required this.duration,
      @required this.lessonType,
      this.isFree,
      this.courseId,
      this.videoUrl,
      this.summary,
      this.attachmentType,
      this.attachment,
      this.attachmentUrl,
      this.isCompleted,
      this.videoUrlWeb,
      this.videoTypeWeb,
      this.vimeoVideoId,
      this.lessonPrice,
      this.lessonDiscountPrice,
      this.lessonExpiryData,
      this.isLessonPurchased,
      this.durationForMobile,
      this.videoTypeMobile,
      this.videoUrlMobile});
}
