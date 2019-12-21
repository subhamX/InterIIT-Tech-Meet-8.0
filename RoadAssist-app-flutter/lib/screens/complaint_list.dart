import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:roadassist/common/common.dart';
import 'package:roadassist/error/errorpage.dart';
import 'package:roadassist/screens/loaders/loading.dart';
import 'package:roadassist/screens/loaders/loadingbox.dart';

class ComplaintsList extends StatefulWidget {
  @override
  _ComplaintsState createState() => _ComplaintsState();
}

class _ComplaintsState extends State<ComplaintsList> {
  Firestore _firestore = Firestore.instance;
  FirebaseAuth _auth = FirebaseAuth.instance;
  Future getData() async {
    var data = [];
    FirebaseUser user = await _auth.currentUser();
    QuerySnapshot complaints = await _firestore
        .collection('complaints')
        .where('uid', isEqualTo: user.uid)
        .getDocuments();

    int size = complaints.documents.length;
    if (size == 0) {
      data.add(
        Container(
          padding: const EdgeInsets.fromLTRB(20, 60, 20, 10),
          alignment: Alignment.center,
          child: Text(
            "THERE ARE NO COMPLAINTS LINKED TO THIS ACCOUNT",
            style: TextStyle(fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ),
      );
      data.add(Image.asset(
        'assets/noform.png',
        height: 250,
      ));
      return data;
    }
    for (int i = 0; i < size; i++) {
      var comp = complaints.documents[i].data;
      var status = comp["status"];
      Icon trailingIcon;
      if (status == 1) {
        trailingIcon = Icon(Icons.device_unknown, color: Colors.purple[800],);
      } else if (status == 2) {
        trailingIcon = Icon(Icons.done_all, color: Colors.purple[800],);
      } else {
        trailingIcon = Icon(Icons.markunread, color: Colors.purple[800],);
      }
      // print();
      var date = new DateTime.fromMillisecondsSinceEpoch(
          comp["timestamp"].seconds * 1000);
      data.add(
        Card(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                // leading: Tab(icon: Image.asset("assets/dashboard.png")),
                trailing: trailingIcon,
                title: Text(
                  comp["name"] ?? "NO_NAME",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
                subtitle: Text(
                    "${date.toLocal().toString().substring(0, 9)} | ${date.toLocal().toString().substring(11, 19)}"),
              ),
              ButtonTheme.bar(
                // make buttons use the appropriate styles for cards
                child: ButtonBar(
                  children: <Widget>[
                    FlatButton(
                      child: Text('DETAILED PROGRESS'),
                      onPressed: () {
                        Navigator.pushNamed(context, 'complaint', arguments: {
                          "uid": user.uid,
                          "id": complaints.documents[i].documentID
                        });
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }
    return data;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: getData(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Scaffold(
              bottomNavigationBar: BottomAppBar(
                elevation: 0,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(25, 0, 25, 0),
                  child: FlatButton(
                    color: Colors.blue[800],
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(
                          Icons.add_box,
                          color: Colors.white,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          'NEW COMPLAINT',
                          style: TextStyle(color: Colors.white),
                        )
                      ],
                    ),
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, 'new_complaint');
                    },
                  ),
                ),
              ),
              appBar: Common.getAppBar(context),
              body: Container(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Column(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Image.asset(
                          'assets/recent-form-icon.png',
                          height: 45,
                        ),
                        SizedBox(
                          width: 8,
                        ),
                        Text(
                          "COMPLAINTS LIST",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 24),
                        ),
                      ],
                    ),
                    Divider(
                      height: 20,
                      indent: 20,
                      endIndent: 20,
                      color: Colors.black,
                    ),
                    ...snapshot.data
                  ],
                ),
              ),
            );
          } else if (snapshot.hasError) {
            return ErrorPage();
          } else {
            return LoadingScreen();
          }
        });
  }
}
