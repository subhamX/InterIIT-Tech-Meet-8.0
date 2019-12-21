import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter/material.dart';

class LoadingWScreen extends StatefulWidget {
  @override
  _LoadingWScreenState createState() => _LoadingWScreenState();
}

class _LoadingWScreenState extends State<LoadingWScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(color: Colors.white),
        child: SpinKitRipple(
          color: Colors.black,
          size: 150,
        ),
      ),
    );
  }
}
