import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:news/firebaseConfig.dart';
import 'package:news/services/yetkilendirmeServisi.dart';
import 'package:news/services/yonlendirme.dart';
import 'package:provider/provider.dart';

import 'constants.dart';

final Config _config = Config();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: FirebaseOptions(
          apiKey: _config.apiKey,
          appId: _config.appId,
          messagingSenderId: _config.messagingSenderId,
          projectId: _config.projectId,
          measurementId: _config.measurementId,
          authDomain: _config.authDomain,
          storageBucket: _config.storageBucket));
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Provider<YetkilendirmeServisi>(
      create: (_) => YetkilendirmeServisi(),
      child: GetMaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'BeyceWeb',
        theme: ThemeData(
          primaryColor: kPrimaryColor,
          scaffoldBackgroundColor: kBgColor,
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: TextButton.styleFrom(backgroundColor: kPrimaryColor),
          ),
          textTheme: TextTheme(
            bodyText1: TextStyle(color: kBodyTextColor),
            bodyText2: TextStyle(color: kBodyTextColor),
            headline5: TextStyle(color: kDarkBlackColor),
          ),
        ),
        home: Yonlendirme(),
      ),
    );
  }
}
