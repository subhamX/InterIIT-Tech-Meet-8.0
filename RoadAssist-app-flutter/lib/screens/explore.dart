import 'package:flutter/material.dart';
import 'package:intro_views_flutter/Models/page_view_model.dart';
import 'package:intro_views_flutter/intro_views_flutter.dart';

class Explore extends StatelessWidget {
  final pages = [
    PageViewModel(
      pageColor: Colors.white,
      bubbleBackgroundColor: Colors.blue[900],
      title: Container(),
      body: Column(
        children: <Widget>[
          Text('Disappointed from Bad Roads?'),
          Text(
            'Want to bring change but don\'t want to get into the hassle of tedious procedures?',
            style: TextStyle(
              color: Colors.black54,
              fontSize: 16.0,
            ),
          ),
        ],
      ),
      mainImage: Image.asset(
        'assets/explore/image.png',
        width: 285.0,
        alignment: Alignment.center,
      ),
      textStyle: TextStyle(color: Colors.black),
    ),
    PageViewModel(
      pageColor: Colors.white,
      iconColor: null,
      bubbleBackgroundColor: Colors.blue[900],
      title: Container(),
      body: Column(
        children: <Widget>[
          Text('Digitally fill the feedback'),
          Text(
            'Mark the road location and give your wise suggestions and help us change the conditions of road',
            style: TextStyle(
              color: Colors.black54,
              fontSize: 16.0,
            ),
          ),

        ],
      ),
      mainImage: Image.asset(
        'assets/explore/digital_india.jpg',
        width: 285.0,
        alignment: Alignment.center,
      ),
      textStyle: TextStyle(color: Colors.black),
    ),
    PageViewModel(
      pageColor: Colors.white,
      iconColor: null,
      bubbleBackgroundColor: Colors.blue[900],
      title: Container(),
      body: Column(
        children: <Widget>[
          Text('Use our Native Voice To Speech Converter'),
          Text(
            "Using Road Assist Zero typing feedbacks are now a reality.",
            style: TextStyle(
              color: Colors.black54,
              fontSize: 16.0,
            ),
          ),
        ],
      ),
      mainImage: Image.asset(
        'assets/explore/video3.gif',
        width: 285.0,
        alignment: Alignment.center,
      ),
      textStyle: TextStyle(color: Colors.black),
    ),
    PageViewModel(
      pageColor: Colors.white,
      iconColor: null,
      bubbleBackgroundColor: Colors.blue[900],
      title: Container(),
      body: Column(
        children: <Widget>[
          Text('Allow Road Assist to help you make a change!'),
          Text(
            '🙂',
            style: TextStyle(color: Colors.black54, fontSize: 16.0),
          ),
        ],
      ),
      mainImage: Image.asset(
        'assets/explore/fillForm.png',
        width: 285.0,
        alignment: Alignment.center,
      ),
      textStyle: TextStyle(color: Colors.black),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            IntroViewsFlutter(
              pages,
              onTapDoneButton: () {
                Navigator.pop(context);
              },
              showSkipButton: false,
              doneText: Text("Get Started"),
              pageButtonsColor: Colors.blue[900],
              pageButtonTextStyles: TextStyle(
                fontSize: 16.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
