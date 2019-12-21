import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:roadassist/error/errorpage.dart';
import 'package:roadassist/screens/admincomplaint.dart';
import 'package:roadassist/screens/auth/forgot_pass.dart';
import 'package:roadassist/screens/auth/signin.dart';
import 'package:roadassist/screens/auth/signup.dart';
import 'package:roadassist/screens/complaint.dart';
import 'package:roadassist/screens/complaint_list.dart';
import 'package:roadassist/screens/explore.dart';
import 'package:roadassist/screens/home.dart';
import 'package:roadassist/screens/homeadmin.dart';
import 'package:roadassist/screens/listening_fetch.dart';
import 'package:roadassist/screens/new_complaint.dart';
import 'package:google_map_location_picker/generated/i18n.dart'
    as location_picker;
import 'package:flutter_localizations/flutter_localizations.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  // This widget is the root of your application.
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // @override
  void initState() {
    super.initState();
  }

  Widget _getInitialRoute() {
    return StreamBuilder<FirebaseUser>(
      stream: FirebaseAuth.instance.onAuthStateChanged,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          // Checking if the user is admin
          bool isAdmin = snapshot.data.uid.endsWith('admin');
          if (isAdmin) {
            return AdminHome();
          } else {
            return Home();
          }
        } else {
          return SignIn();
        }
      },
    );
  }
  // Widget _getInitialRoute() {
  //   return FutureBuilder<FirebaseUser>(
  //     future: FirebaseAuth.instance.currentUser(),
  //     builder: (context, snapshot) {
  //       if (snapshot.hasData) {
  //         // Checking if the user is admin
  //         bool isAdmin = snapshot.data.uid.endsWith('admin');
  //         if (isAdmin) {
  //           return AdminHome();
  //         } else {
  //           return Home();
  //         }
  //       } else {
  //         return SignIn();
  //       }
  //     },
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: [
        location_picker.S.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
      ],
      supportedLocales: const <Locale>[
        Locale('en', ''),
        Locale('ar', ''),
      ],
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          fontFamily: 'Lato',
          bottomAppBarColor: Theme.of(context).scaffoldBackgroundColor),
      title: 'Form Assist',
      home: _getInitialRoute(),
      routes: {
        'home': (context) => Home(),
        'adminhome': (context) => AdminHome(),
        // Auth Screens
        'signin': (context) => SignIn(),
        'signup': (context) => SignUp(),
        'forgot_password': (context) => ForgotPassword(),
        'explore': (context) => Explore(),
        'new_complaint': (context) => NewComplaint(),
        'complaint_list': (context) => ComplaintsList(),
        'complaint': (context) => Complaint(),
        'listening_fetch': (context) => ListeningFetch(),
        "admin_complaint_view": (context) => AdminComplaint(),

        // 'profile': (context) => Profile(),
        'error_page': (context) => ErrorPage(),
      },
    );
  }
}
