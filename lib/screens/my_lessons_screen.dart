import 'dart:async';
import 'dart:convert';

import 'package:academy_app/providers/my_bundles.dart';
import 'package:academy_app/providers/my_courses.dart';
import 'package:academy_app/widgets/custom_text.dart';
import 'package:academy_app/widgets/from_youtube.dart';
import 'package:academy_app/widgets/my_bundle_grid.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../constants.dart';

class MyLessonsScreen extends StatefulWidget {
  const MyLessonsScreen({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _MyLessonsScreenState createState() => _MyLessonsScreenState();
}

class _MyLessonsScreenState extends State<MyLessonsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late ScrollController _scrollController;

  ConnectivityResult _connectionStatus = ConnectivityResult.none;
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;

  bool _isLoading = true;
  dynamic bundleStatus = false;

  @override
  void initState() {
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_smoothScrollToTop);
    super.initState();

    addonStatus();

    initConnectivity();

    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  Future<void> initConnectivity() async {
    late ConnectivityResult result;
    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      // ignore: avoid_print
      print(e.toString());
      return;
    }
    if (!mounted) {
      return Future.value(null);
    }

    return _updateConnectionStatus(result);
  }

  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    setState(() {
      _connectionStatus = result;
    });
  }

  _scrollListener() {
    // if (fixedScroll) {
    //   _scrollController.jumpTo(0);
    // }
  }

  _smoothScrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(microseconds: 300),
      curve: Curves.ease,
    );
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  Future<void> addonStatus() async {
    var url = '$BASE_URL/api/addon_status?unique_identifier=course_bundle';
    final response = await http.get(Uri.parse(url));
    setState(() {
      _isLoading = false;
      bundleStatus = json.decode(response.body)['status'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                  color: kPrimaryColor.withOpacity(0.7)),
            )
          : bundleStatus == true
              ? NestedScrollView(
                  controller: _scrollController,
                  headerSliverBuilder: (context, value) {
                    return [
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 15.0, vertical: 10),
                          child: TabBar(
                            controller: _tabController,
                            isScrollable: false,
                            indicatorColor: kPrimaryColor,
                            indicatorSize: TabBarIndicatorSize.tab,
                            indicator: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: kPrimaryColor),
                            unselectedLabelColor: Colors.black87,
                            labelColor: Colors.white,
                            tabs: const [
                              Tab(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.play_lesson,
                                      size: 15,
                                    ),
                                    Text(
                                      'My Lessons',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Tab(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.all_inbox,
                                      size: 15,
                                    ),
                                    Text(
                                      'My Bundles',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ];
                  },
                  body: TabBarView(
                    controller: _tabController,
                    children: [
                      lessonView(),
                      bundleView(),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 20),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                              'My Lessons',
                              style: TextStyle(
                                  fontWeight: FontWeight.w400, fontSize: 20),
                            ),
                          ],
                        ),
                      ),
                      lessonView(),
                    ],
                  ),
                ),
    );
  }

  Widget lessonView() {
    return FutureBuilder(
      future: Provider.of<MyCourses>(context, listen: false).fetchMyLessons(),
      builder: (ctx, dataSnapshot) {
        if (dataSnapshot.connectionState == ConnectionState.waiting) {
          return SizedBox(
            height: MediaQuery.of(context).size.height * .7,
            child: Center(
              child: CircularProgressIndicator(
                  color: kPrimaryColor.withOpacity(0.7)),
            ),
          );
        } else {
          if (dataSnapshot.error != null) {
            //error
            return _connectionStatus == ConnectivityResult.none
                ? Center(
                    child: Column(
                      children: [
                        SizedBox(
                            height: MediaQuery.of(context).size.height * .15),
                        Image.asset(
                          "assets/images/no_connection.png",
                          height: MediaQuery.of(context).size.height * .35,
                        ),
                        const Padding(
                          padding: EdgeInsets.all(4.0),
                          child: Text('There is no Internet connection'),
                        ),
                        const Padding(
                          padding: EdgeInsets.all(4.0),
                          child: Text('Please check your Internet connection'),
                        ),
                      ],
                    ),
                  )
                : Center(
                    // child: Text('Error Occured'),
                    child: Text(dataSnapshot.error.toString()),
                  );
          } else {
            return Consumer<MyCourses>(
              builder: (context, myCourseData, child) =>
                  myCourseData.lessonItems.isNotEmpty
                      ? AlignedGridView.count(
                          padding: const EdgeInsets.all(10.0),
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 2,
                          itemCount: myCourseData.lessonItems.length,
                          itemBuilder: (ctx, index) {
                            return InkWell(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          PlayVideoFromYoutube(
                                              courseId: myCourseData
                                                  .lessonItems[index].courseId!,
                                              videoUrl: myCourseData
                                                  .lessonItems[index].videoUrl
                                                  .toString()),
                                    ));
                              },
                              child: Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                elevation: 0.1,
                                child: Column(
                                  children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          bottom: 5, right: 8, left: 8, top: 5),
                                      child: SizedBox(
                                        height: 42,
                                        child: CustomText(
                                          text: myCourseData
                                                      .lessonItems[index].title
                                                      .toString()
                                                      .length <
                                                  38
                                              ? myCourseData
                                                  .lessonItems[index].title
                                              : myCourseData
                                                  .lessonItems[index].title!
                                                  .substring(0, 37),
                                          fontSize: 14,
                                          colors: kTextLightColor,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                          mainAxisSpacing: 5.0,
                          crossAxisSpacing: 5.0,
                        )
                      : const Center(
                          child: CustomText(
                            text: "The isn't any bought lessons yet",
                            fontSize: 18,
                          ),
                        ),
            );
          }
        }
      },
    );
  }

  Widget bundleView() {
    return SingleChildScrollView(
      child: FutureBuilder(
        future: Provider.of<MyBundles>(context, listen: false).fetchMybundles(),
        builder: (ctx, dataSnapshot) {
          if (dataSnapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                  color: kPrimaryColor.withOpacity(0.7)),
            );
          } else {
            if (dataSnapshot.error != null) {
              //error
              return _connectionStatus == ConnectivityResult.none
                  ? Center(
                      child: Column(
                        children: [
                          SizedBox(
                              height: MediaQuery.of(context).size.height * .15),
                          Image.asset(
                            "assets/images/no_connection.png",
                            height: MediaQuery.of(context).size.height * .35,
                          ),
                          const Padding(
                            padding: EdgeInsets.all(4.0),
                            child: Text('There is no Internet connection'),
                          ),
                          const Padding(
                            padding: EdgeInsets.all(4.0),
                            child:
                                Text('Please check your Internet connection'),
                          ),
                        ],
                      ),
                    )
                  : Center(
                      // child: Text('Error Occured'),
                      child: Text(dataSnapshot.error.toString()),
                    );
            } else {
              return Consumer<MyBundles>(
                builder: (context, myBundleData, child) =>
                    AlignedGridView.count(
                  padding: const EdgeInsets.all(10.0),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  itemCount: myBundleData.bundleItems.length,
                  itemBuilder: (ctx, index) {
                    return MyBundleGrid(
                      myBundle: myBundleData.bundleItems[index],
                    );
                    // return Text(myCourseData.items[index].title);
                  },
                  mainAxisSpacing: 5.0,
                  crossAxisSpacing: 5.0,
                ),
              );
            }
          }
        },
      ),
    );
  }
}
