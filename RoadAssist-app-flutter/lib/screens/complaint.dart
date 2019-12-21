import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:roadassist/common/common.dart';
import 'package:roadassist/error/errorpage.dart';
import 'package:roadassist/screens/loaders/loading.dart';
import 'package:roadassist/screens/loaders/loading_white.dart';
import 'package:roadassist/screens/loaders/loadingbox.dart';

class Complaint extends StatefulWidget {
  @override
  _ComplaintsState createState() => _ComplaintsState();
}

class _ComplaintsState extends State<Complaint> {
  Firestore _firestore = Firestore.instance;
  String index, docId;

  Widget getStatusWidget(int status) {
    String statusText;
    Color color;
    if (status == 0) {
      statusText = "ACTIVE";
      color = Colors.brown;
    } else if (status == 1) {
      statusText = "IN PROGRESS";
      color = Colors.orange[800];
    } else {
      color = Colors.green[800];
      statusText = "RESOLVED";
    }
    return Text(
      "$statusText",
      style: TextStyle(color: color),
    );
  }

  Widget getRatingWidget(int rating) {
    List<String> ratingOptions = Common.ratingOptions;
    String ratingText = ratingOptions[rating - 1];
    List<Color> ratingColors = Common.ratingColors;
    Color color = ratingColors[rating - 1];
    return Text(
      "$ratingText",
      style: TextStyle(color: color),
    );
  }

  Future getData() async {
    var data = [];
    
    DocumentReference complaintRef =
        _firestore.collection('complaints').document(docId);
    DocumentSnapshot complaint = await complaintRef.get();
    var comp = complaint.data;
    var status = comp["status"];
    Icon trailingIcon;
    if (status == 1) {
      trailingIcon = Icon(Icons.device_unknown);
    } else if (status == 2) {
      trailingIcon = Icon(Icons.done_all);
    } else {
      trailingIcon = Icon(Icons.markunread);
    }
    var date = new DateTime.fromMillisecondsSinceEpoch(
        comp["timestamp"].seconds * 1000);
    data.add(
      Card(
        elevation: 0,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: Tab(icon: Image.asset("assets/form-icon.png")),
              title: Text(
                "ROAD NAME",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                comp["name"] ?? "NO_NAME",
              ),
            ),
            ListTile(
              leading: Tab(
                icon: Image.asset('assets/icons/date.png'),
              ),
              title: Text(
                "Submission Date".toUpperCase(),
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                  "${date.toLocal().toString().substring(0, 9)} | ${date.toLocal().toString().substring(11, 19)}"),
            ),
            ListTile(
              leading: Tab(
                icon: Image.asset('assets/icons/rating.png'),
              ),
              title: Text(
                'Rating'.toUpperCase(),
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: getRatingWidget(comp["rating"]),
            ),
            ListTile(
              leading: Tab(
                icon: Image.asset('assets/icons/status.png'),
              ),
              title: Text(
                'Status'.toUpperCase(),
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: getStatusWidget(comp["status"]),
            ),
            ListTile(
              leading: Tab(
                icon: Image.asset('assets/icons/location.png'),
              ),
              title: Text(
                "Location".toUpperCase(),
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                  "Latitude: ${comp["location"][0].toString().substring(0, 6)} Longitude: ${comp["location"][1].toString().substring(0, 6)}"),
            ),
            ListTile(
              leading: Tab(
                icon: Image.asset('assets/icons/note.png'),
              ),
              title: Text(
                "Suggestions".toUpperCase(),
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text("${comp["suggestions"] ?? "NO_TEXT"}"),
            ),
                        Divider(
              height: 10,
              color: Colors.black,
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              child: Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Tab(
                        icon: Image.asset(
                          'assets/icons/image.png',
                          height: 70,
                        ),
                      ),
                      Text(
                        'Uploaded Images'.toUpperCase(),
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            fontSize: 17, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  Container(
                    decoration:
                        BoxDecoration(border: Border.all(color: Colors.black)),
                    child: Image.network(
                      comp["imageurl"],
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

        QuerySnapshot actions = await complaintRef
        .collection('actions')
        .orderBy('timestamp', descending: true)
        .getDocuments();
    int size = actions.documents.length;
    if (size == 0) {
      data.add(Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Tab(
              icon: Image.asset('assets/icons/actions.png'),
            ),
            Text(
              "NO ACTIONS TAKEN YET",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ));
    } else {
      data.add(
        Divider(
          height: 10,
          color: Colors.black,
        ),
      );
      data.add(
        SizedBox(
          height: 10,
        ),
      );
      data.add(Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Tab(
              icon: Image.asset('assets/icons/actions.png'),
            ),
            Text(
              "ACTIONS",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ));
    }

    for (int i = 0; i < size; i++) {
      var actionDoc = actions.documents[i].data;
      var date = new DateTime.fromMillisecondsSinceEpoch(
          comp["timestamp"].seconds * 1000);
      data.add(Card(
        elevation: 0,
        color: i % 2 == 0 ? Colors.amberAccent : Colors.white,
        child: Container(
          width: MediaQuery.of(context).size.width,
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Wrap(
                children: <Widget>[
                  Text(
                    "Actions Taken",
                    maxLines: 1,
                    style: TextStyle(
                        color: Colors.purple, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text("${actionDoc["actions"]}"),
                ],
              ),
              SizedBox(
                height: 20,
              ),
              Wrap(
                children: <Widget>[
                  Text(
                    "Timestamp: ",
                    maxLines: 1,
                    style: TextStyle(
                        color: Colors.brown[700], fontWeight: FontWeight.w600),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                      "${date.toLocal().toString().substring(0, 9)} | ${date.toLocal().toString().substring(11, 19)}"),
                ],
              ),
            ],
          ),
        ),
      ));
      // data.add(Text());
    }
    return data;
  }

  @override
  Widget build(BuildContext context) {
    final args = Map.from(ModalRoute.of(context).settings.arguments);
    index = args["pageNumber"];
    docId = args["id"];
    return FutureBuilder(
        future: getData(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Scaffold(
              appBar: Common.getAppBar(context),
              body: SingleChildScrollView(
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Column(
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Image.asset(
                            'assets/edit-form-icon.png',
                            height: 40,
                          ),
                          SizedBox(
                            width: 8,
                          ),
                          Text(
                            "COMPLAINT",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 24),
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
                                "Viewing Mode",
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
                      SizedBox(
                        height: 10,
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
            return LoadingScreen();
          }
        });
  }
}
