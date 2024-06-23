// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:academy_app/models/common_functions.dart';
import 'package:academy_app/providers/courses.dart';
import 'package:academy_app/providers/shared_pref_helper.dart';
import 'package:academy_app/screens/vimeo_iframe.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../constants.dart';
import '../models/lesson.dart';
import 'from_network.dart';
import 'from_youtube.dart';

class LessonListItem extends StatefulWidget {
  final Lesson? lesson;
  final int courseId;
  final bool isCoursePurchased;

  const LessonListItem(
      {Key? key,
      @required this.lesson,
      required this.courseId,
      required this.isCoursePurchased})
      : super(key: key);

  @override
  State<LessonListItem> createState() => _LessonListItemState();
}

class _LessonListItemState extends State<LessonListItem> {
  void lessonAction(Lesson lesson) async {
    if (lesson.lessonType == 'video') {
      if (lesson.videoTypeWeb == 'system' ||
          lesson.videoTypeWeb == 'html5' ||
          lesson.videoTypeWeb == 'amazon') {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => PlayVideoFromNetwork(
                  courseId: widget.courseId,
                  lessonId: lesson.id!,
                  videoUrl: lesson.videoUrlWeb!)),
        );
      } else if (lesson.videoTypeWeb == 'Vimeo') {
        String vimeoVideoId = lesson.videoUrlWeb!.split('/').last;
        // Navigator.push(
        //     context,
        //     MaterialPageRoute(
        //       builder: (context) => PlayVideoFromVimeoId(
        //           courseId: widget.courseId,
        //           lessonId: lesson.id!,
        //           vimeoVideoId: vimeoVideoId),
        //     ));
        String vimUrl = 'https://player.vimeo.com/video/$vimeoVideoId';
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => VimeoIframe(url: vimUrl)));
      } else {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PlayVideoFromYoutube(
                  courseId: widget.courseId,
                  lessonId: lesson.id!,
                  videoUrl: lesson.videoUrlWeb!),
            ));
      }
    }
  }

  IconData getLessonIcon(String lessonType) {
    // print(lessonType);
    if (lessonType == 'video') {
      return Icons.play_arrow;
    } else if (lessonType == 'quiz') {
      return Icons.help_outline;
    } else {
      return Icons.attach_file;
    }
  }

  String? _authToken;

  void _launchURL(String url) async => await canLaunch(url)
      ? await launch(url, forceSafariVC: false)
      : throw 'Could not launch $url';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: Icon(
                      getLessonIcon(widget.lesson!.lessonType.toString()),
                      size: 14,
                      color: Colors.black45,
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text(widget.lesson!.title.toString(),
                        style: const TextStyle(
                            fontSize: 14, color: Colors.black45)),
                  ),
                  if (widget.lesson!.isFree == '1')
                    InkWell(
                      onTap: () {
                        lessonAction(widget.lesson!);
                      },
                      child: const Row(
                        children: [
                          Icon(
                            Icons.remove_red_eye_outlined,
                            size: 15,
                            color: kBlueColor,
                          ),
                          Text(
                            ' Preview',
                            style: TextStyle(
                              color: kBlueColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              if (!widget.isCoursePurchased)
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsetsDirectional.only(start: 20),
                      child: Text(
                          widget.lesson!.isFree == '0'
                              ? "${widget.lesson!.lessonDiscountPrice == '0' ? widget.lesson!.lessonPrice : widget.lesson!.lessonDiscountPrice} \$"
                              : "Free",
                          style: const TextStyle(
                              fontSize: 14, color: Colors.blue)),
                    ),
                    if (widget.lesson!.lessonDiscountPrice != null &&
                        widget.lesson!.lessonDiscountPrice != "0")
                      Padding(
                        padding: const EdgeInsetsDirectional.only(start: 10),
                        child: Text("${widget.lesson!.lessonPrice} \$",
                            style: const TextStyle(
                                fontSize: 12,
                                color: Colors.blue,
                                decoration: TextDecoration.lineThrough)),
                      ),
                    const Spacer(),
                    MaterialButton(
                      onPressed: () async {
                        _authToken =
                            await SharedPreferenceHelper().getAuthToken();
                        if (!widget.lesson!.isLessonPurchased!) {
                          if (_authToken != null) {
                            if (widget.lesson!.isFree == '1') {
                              Provider.of<Courses>(context, listen: false)
                                  .getLessonEnrolled(widget.lesson!.id!)
                                  .then((_) => CommonFunctions.showSuccessToast(
                                      'Lesson Enrolled Successfully'));
                            } else {
                              final url =
                                  '$AMIN_BASE_URL/api/web_redirect_to_buy_lesson/$_authToken/${widget.lesson!.id}/academybycreativeitem';
                              _launchURL(url);
                            }
                          } else {
                            CommonFunctions.showSuccessToast(
                                'Please login first');
                          }
                        }
                      },
                      color: widget.lesson!.isLessonPurchased!
                          ? kGreenPurchaseColor
                          : kPrimaryColor,
                      textColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 10),
                      splashColor: Colors.blueAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(7.0),
                      ),
                      child: Text(
                        widget.lesson!.isLessonPurchased!
                            ? 'Lesson Purchased'
                            : widget.lesson!.isFree == '1'
                                ? 'Get Enroll'
                                : 'Buy This Lesson',
                        style: const TextStyle(
                            fontWeight: FontWeight.w400, fontSize: 16),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
        const Divider(),
      ],
    );
  }
}
