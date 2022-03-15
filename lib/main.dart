import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hitstorm/backend/DatabaseRequests.dart';
import 'package:hitstorm/frontend/CreateAccountSteps/UserDataScreen.dart';
import 'package:hitstorm/frontend/views/Overview.dart';
import 'package:hitstorm/frontend/CreateAccountSteps/SignUpView.dart';

bool loggedIn = false;

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await DatabaseRequests.init();
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
        navigatorKey: NavigationService.navigatorKey, // set property
        theme: ThemeData(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          hoverColor: Colors.transparent,
        ),
        initialRoute: DatabaseRequests.auth.currentUser == null ? "startScreen": "themeView",
        routes: {
          "startScreen": (context) => SignUpView(),
          "loginScreen": (context) => UserDataScreen(),
          "themeView": (context) => Overview(t: null),
        },
      ),
    );
  }
}
class NavigationService {
  static GlobalKey<NavigatorState> navigatorKey =
  GlobalKey<NavigatorState>();
}

