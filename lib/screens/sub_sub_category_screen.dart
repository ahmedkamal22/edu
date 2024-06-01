import 'dart:async';

import 'package:academy_app/constants.dart';
import 'package:academy_app/providers/categories.dart';
import 'package:academy_app/widgets/sub_sub_category_list_item.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class SubSubCategoryScreen extends StatefulWidget {
  static const routeName = '/sub-sub';

  const SubSubCategoryScreen({Key? key}) : super(key: key);

  @override
  _SubSubCategoryScreenState createState() => _SubSubCategoryScreenState();
}

class _SubSubCategoryScreenState extends State<SubSubCategoryScreen> {
  ConnectivityResult _connectionStatus = ConnectivityResult.none;
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    initConnectivity();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  Future<void> initConnectivity() async {
    late ConnectivityResult result;
    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
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

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final routeArgs =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final subCatId = routeArgs['sub_category_id'] as int;
    final title = routeArgs['title'];

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(title, maxLines: 2),
        titleTextStyle: const TextStyle(color: Colors.black, fontSize: 15),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(
          color: Colors.black,
        ),
      ),
      backgroundColor: kBackgroundColor,
      body: SingleChildScrollView(
        child: FutureBuilder(
          future: Provider.of<Categories>(context, listen: false)
              .fetchSubSubCategories(subCatId),
          builder: (ctx, dataSnapshot) {
            if (dataSnapshot.connectionState == ConnectionState.waiting) {
              return SizedBox(
                height: MediaQuery.of(context).size.height * .5,
                child: Center(
                  child: CircularProgressIndicator(
                      color: kPrimaryColor.withOpacity(0.7)),
                ),
              );
            } else if (dataSnapshot.hasError) {
              print('Error occurred: ${dataSnapshot.error}');
              return _connectionStatus == ConnectivityResult.none
                  ? _buildNoConnectionWidget(context)
                  : const Center(
                      child: Text('An error occurred while fetching data.'));
            } else {
              return Consumer<Categories>(
                builder: (context, categoryData, child) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: const Text(
                          'Go to course',
                          style: TextStyle(
                            fontWeight: FontWeight.w300,
                            fontSize: 17,
                          ),
                        ),
                      ),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: categoryData.subSubItems.length,
                        itemBuilder: (ctx, index) {
                          final item = categoryData.subSubItems[index];
                          return SubSubCategoryListItem(
                            id: item.id,
                            subCatId: item.subId,
                            parent: item.parent,
                            name: item.title,
                            numberOfCourses: item.numberOfCourses,
                            index: index,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildNoConnectionWidget(BuildContext context) {
    return Center(
      child: Column(
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * .15),
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
    );
  }
}
