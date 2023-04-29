import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:news/constants.dart';
import 'package:news/screens/home/loginned_homeScreen.dart';
import 'package:news/screens/main/components/loginnedHeader.dart';
import 'package:news/screens/main/components/side_menu.dart';


// ignore: camel_case_types
class loginnedMainScreen extends StatelessWidget {
  final MenuController _controller = Get.put(MenuController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //key: _controller.scaffoldkey,
      drawer: SideMenu(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            loginnedHeader(),
            Container(
              padding: EdgeInsets.all(kDefaultPadding),
              constraints: BoxConstraints(maxWidth: kMaxWidth),
              child: SafeArea(child: loginned_homeScreen()),
            ),
          ],
        ),
      ),
    );
  }
}
