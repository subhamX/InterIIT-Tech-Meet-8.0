import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:roadassist/common/common.dart';
import 'package:roadassist/error/errorpage.dart';
import 'package:roadassist/screens/loaders/loading_white.dart';

class UnresolvedComplaints extends StatefulWidget {
  @override
  _UnresolvedComplaintsState createState() => _UnresolvedComplaintsState();
}

class _UnresolvedComplaintsState extends State<UnresolvedComplaints> {
  Firestore _firestore = Firestore.instance;
  Future getData() async {
    var data = [];
    QuerySnapshot complaints = await _firestore
        .collection('complaints')
        .where('status', isEqualTo: 1)
        .getDocuments();
    int size = complaints.documents.length;
    if (size == 0) {
      data.add(SizedBox(
        height: 40,
      ));
      data.add(
        Container(
            padding: const EdgeInsets.fromLTRB(8, 5, 8, 0),
            alignment: Alignment.center,
            child: Icon(Icons.check_circle)),
      );
      data.add(
        Container(
          padding: const EdgeInsets.fromLTRB(8, 5, 8, 0),
          alignment: Alignment.center,
          child: Text(
            'There are no unread complaints',
            style: TextStyle(fontSize: 14),
          ),
        ),
      );
      data.add(
        Container(
          padding: const EdgeInsets.all(8.0),
          alignment: Alignment.center,
          child: Text(
            'Please go to unresolved section to update status of unresolved complaints',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12),
          ),
        ),
      );
      data.add(
        SizedBox(
          height: 10,
        ),
      );
      return data;
    }
    data.add(Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      child: Align(
        alignment: Alignment.topLeft,
        child: Text(
          "*Tap to view the complaint and update status",
          style: TextStyle(
            color: Colors.black54,
            fontWeight: FontWeight.w700,
            fontSize: 11,
          ),
        ),
      ),
    ));
    data.add(SizedBox(
      height: 10,
    ));

    for (int i = 0; i < size; i++) {
      var comp = complaints.documents[i].data;
      Icon trailingIcon;
      var date = new DateTime.fromMillisecondsSinceEpoch(
          comp["timestamp"].seconds * 1000);
      data.add(
        Card(
          elevation: 0,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.collections,
                    color: Common.ratingColorsFun(comp["status"])),
                trailing: trailingIcon,
                title: Text(
                  comp["name"] ?? "NO_NAME",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
                subtitle: Text(
                  "${date.toLocal().toString().substring(0, 9)} | ${date.toLocal().toString().substring(11, 19)}",
                ),
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    'admin_complaint_view',
                    arguments: {
                      "id": complaints.documents[i].documentID,
                      "pageNumber": 1,
                    },
                  );
                },
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
            body: SingleChildScrollView(
              child: Container(
                child: Column(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Image.asset(
                          'assets/form-preview.png',
                          height: 55,
                        ),
                        SizedBox(
                          width: 8,
                        ),
                        Text(
                          "ACTIVE COMPLAINTS",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 20),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 16, 0),
                      child: Align(
                        alignment: Alignment.bottomRight,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            Icon(Icons.remove_red_eye),
                            SizedBox(
                              width: 2,
                            ),
                            Text(
                              "Admin Viewing Mode",
                              style: TextStyle(
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Divider(
                      height: 15,
                      indent: 20,
                      endIndent: 20,
                      color: Colors.black,
                    ),
                    ...snapshot.data
                  ],
                ),
              ),
            ),
          );
        } else if (snapshot.hasError) {
          return ErrorPage();
        } else {
          return LoadingWScreen();
        }
      },
    );
  }
}
