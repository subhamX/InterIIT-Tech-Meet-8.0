import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:roadassist/common/common.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:roadassist/screens/recent_complaint.dart';
import 'package:roadassist/screens/resolved_complaint.dart';
import 'package:roadassist/screens/unresolved_complaint.dart';

class AdminHome extends StatefulWidget {
  @override
  _AdminHomeState createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  int _currentIndex = 0;
  final List<Widget> _children = [
    RecentComplaints(),
    UnresolvedComplaints(),
    ResolvedComplaints(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: Common.getAppBar(context),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          items: [
            BottomNavigationBarItem(
              title: Text('Just Arrived'),
              icon: Tab(
                icon: Image.asset('assets/icons/recent.png'),
              ),
            ),
            BottomNavigationBarItem(
                title: Text('Active'),
                icon: Tab(
                  icon: Image.asset('assets/icons/active.png'),
                )),
            BottomNavigationBarItem(
                title: Text('Resolved'),
                icon: Tab(
                  icon: Image.asset('assets/icons/resolved.png'),
                )),
          ],
        ),
        body: _children[_currentIndex]);
  }
}
