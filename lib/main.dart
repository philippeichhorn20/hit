import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hitstorm/backend/DatabaseRequests.dart';
import 'package:hitstorm/backend/ScreenNameGenerator.dart';
import 'package:hitstorm/backend/Theme.dart';
import 'package:hitstorm/firebase_options.dart';
import 'package:hitstorm/frontend/CreateAccountSteps/UserDataScreen.dart';
import 'package:hitstorm/frontend/CreateAccountSteps/WelcomeView.dart';
import 'package:hitstorm/frontend/views/Overview.dart';
import 'package:hitstorm/frontend/CreateAccountSteps/SignUpView.dart';
import 'package:hitstorm/backend/Theme.dart' as bT;


bool loggedIn = false;

void main() async{


  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await DatabaseRequests.init().timeout(Duration(seconds: 3), onTimeout: () => DatabaseRequests.auth.signOut() == null);
  runApp(
    MyApp()
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => FocusManager.instance.primaryFocus?.unfocus(),
      child: MaterialApp(
        navigatorKey: NavigationService.navigatorKey,
        // set property
        theme: ThemeData(
          primaryColor: Colors.green,
          scaffoldBackgroundColor: Colors.white,
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 0,

          ),
          textTheme: TextTheme(
            headline5: TextStyle(
              color: Colors.black45,

            ),
            caption: TextStyle(
              color: Colors.black45, fontWeight: FontWeight.w300
            ),

            bodyText1: TextStyle(
                color: Colors.black45, fontSize: 10.0, fontWeight: FontWeight.w300),
            bodyText2: TextStyle(
                color: Colors.black54, fontSize: 15.0, fontWeight: FontWeight.w400),
          ),
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          hoverColor: Colors.transparent,
        ),
        initialRoute: DatabaseRequests.auth.currentUser == null ? "startScreen": "themeView",
        routes: {
          "startScreen": (context) => WelcomeView(),
          "loginScreen": (context) => UserDataScreen(),
          "themeView": (context) => Overview(t: bT.Theme.topTheme()),
        },
      ),
    );
  }
}
class NavigationService {
  static GlobalKey<NavigatorState> navigatorKey =
  GlobalKey<NavigatorState>();
}

