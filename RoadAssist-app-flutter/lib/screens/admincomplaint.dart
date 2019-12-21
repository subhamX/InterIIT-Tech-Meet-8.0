import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:roadassist/common/common.dart';
import 'package:roadassist/error/errorpage.dart';
import 'package:roadassist/screens/loaders/loading.dart';
import 'package:roadassist/screens/loaders/loadingbox.dart';
import 'package:roadassist/services/suggestionService.dart';

class AdminComplaint extends StatefulWidget {
  @override
  _ComplaintsState createState() => _ComplaintsState();
}

class _ComplaintsState extends State<AdminComplaint> {
  Firestore _firestore = Firestore.instance;
  String uid, docId;
  int index;
  String _roadName = "";
  final _nameKey = GlobalKey<FormState>();
  final _actionKey = GlobalKey<FormState>();

  final actionController = TextEditingController();
  final roadNameController = TextEditingController();
  @override
  void dispose() {
    roadNameController.dispose();
    actionController.dispose();
    super.dispose();
  }

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
      "Status: $statusText",
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

  // Helper Function To Set Data
  void setData(String input) {
    roadNameController.text = input;
    _roadName = input;
  }

  void setDataAction(String input) {
    actionController.text = input;
  }

  Future getData() async {
    var data = [];
    DocumentReference complaintRef =
        _firestore.collection('complaints').document(docId);
    DocumentSnapshot complaint = await complaintRef.get();
    var comp = complaint.data;
    var status = comp["status"];
    _roadName = comp["name"];

    var date = new DateTime.fromMillisecondsSinceEpoch(
        comp["timestamp"].seconds * 1000);
    data.add(
      Card(
        elevation: 0,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Column(children: <Widget>[
              ListTile(
                leading: Tab(icon: Image.asset("assets/form-icon.png")),
                title: Text(
                  "ROAD NAME",
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(_roadName ?? ""),
                onTap: () {
                  showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          content: Form(
                            key: _nameKey,
                            child: TypeAheadFormField(
                              textFieldConfiguration: TextFieldConfiguration(
                                decoration: InputDecoration(
                                  labelText: "Road Name",
                                ),
                                controller: roadNameController,
                              ),
                              suggestionsCallback: (pattern) {
                                return SuggestionService.getSuggestions(
                                    pattern);
                              },
                              itemBuilder: (context, suggestion) {
                                return ListTile(
                                  title: Text(suggestion),
                                );
                              },
                              onSuggestionSelected: (suggestion) {
                                roadNameController.text = suggestion;
                              },
                              transitionBuilder:
                                  (context, suggestionsBox, controller) {
                                return suggestionsBox;
                              },
                              validator: (input) {
                                if (input.length > 0) {
                                  return null;
                                } else {
                                  return "Please Enter a valid Road Name";
                                }
                              },
                            ),
                          ),
                          actions: <Widget>[
                            Container(
                              child: RaisedButton(
                                  color: Colors.blue,
                                  onPressed: () async {
                                    await Navigator.pushNamed(
                                      context,
                                      'listening_fetch',
                                      arguments: {
                                        "setData": setData,
                                      },
                                    );
                                  },
                                  child: Row(
                                    children: <Widget>[
                                      Text(
                                        'MIC',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      Icon(
                                        Icons.mic,
                                        color: Colors.white,
                                      ),
                                    ],
                                  )),
                            ),
                            RaisedButton(
                              color: Colors.blue,
                              child: Text(
                                "UPDATE ROAD NAME",
                                style: TextStyle(color: Colors.white),
                              ),
                              onPressed: () async {
                                if (_nameKey.currentState.validate()) {
                                  showDialog(
                                      context: context,
                                      barrierDismissible: false,
                                      builder: (context) {
                                        return LoadingBox();
                                      });
                                  DocumentReference docRef = _firestore
                                      .collection('complaints')
                                      .document(docId);
                                  await docRef.updateData(
                                    {"name": roadNameController.text},
                                  );
                                  setState(() {
                                    _roadName = roadNameController.text;
                                  });

                                  Navigator.of(context).pop();
                                  Navigator.of(context).pop();
                                  Flushbar(
                                    message: "Road Name Updation Successful!",
                                    duration: Duration(seconds: 1),
                                  ).show(context);
                                }
                              },
                            ),
                          ],
                        );
                      });
                },
                trailing: Icon(
                  Icons.edit,
                  color: Colors.purple,
                ),
              ),
            ]),
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
                icon: Image.asset('assets/icons/location.png'),
              ),
              title: Text(
                "Location".toUpperCase(),
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                "Latitude: ${comp["location"][0].toString().substring(0, 6)}   Longitude: ${comp["location"][1].toString().substring(0, 6)}",
              ),
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
    if (index == 0) {
      // TODO: CHECK
      // await _firestore
      //     .collection('complaints')
      //     .document(docId)
      //     .updateData({"status": 1});
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
              bottomNavigationBar: index != 2
                  ? Padding(
                      padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: FlatButton(
                              color: Colors.blue[800],
                              onPressed: () {
                                // SHAHSHSA
                                showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        content: Form(
                                          key: _actionKey,
                                          child: TextFormField(
                                            decoration: InputDecoration(
                                              labelText: "Actions Taken",
                                            ),
                                            controller: actionController,
                                            validator: (input) {
                                              if (input.length > 0) {
                                                return null;
                                              } else {
                                                return "Please Enter a valid Action Taken";
                                              }
                                            },
                                          ),
                                        ),
                                        actions: <Widget>[
                                          Container(
                                            child: RaisedButton(
                                                color: Colors.blue,
                                                onPressed: () async {
                                                  await Navigator.pushNamed(
                                                    context,
                                                    'listening_fetch',
                                                    arguments: {
                                                      "setData": setDataAction,
                                                    },
                                                  );
                                                },
                                                child: Row(
                                                  children: <Widget>[
                                                    Text(
                                                      'MIC',
                                                      style: TextStyle(
                                                          color: Colors.white),
                                                    ),
                                                    Icon(
                                                      Icons.mic,
                                                      color: Colors.white,
                                                    ),
                                                  ],
                                                )),
                                          ),
                                          RaisedButton(
                                            color: Colors.blue,
                                            child: Text(
                                              "ADD ACTION",
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                            onPressed: () async {
                                              if (_actionKey.currentState
                                                  .validate()) {
                                                showDialog(
                                                    context: context,
                                                    barrierDismissible: false,
                                                    builder: (context) {
                                                      return LoadingBox();
                                                    });
                                                await _firestore
                                                    .collection('complaints')
                                                    .document(docId)
                                                    .collection('actions')
                                                    .add({
                                                  "timestamp": DateTime.now(),
                                                  "actions":
                                                      actionController.text
                                                });
                                                actionController.text = "";
                                                Flushbar(
                                                  message:
                                                      "Action Successfully Added!",
                                                  duration:
                                                      Duration(seconds: 1),
                                                ).show(context);
                                                await Future.delayed(
                                                    Duration(seconds: 2));
                                                Navigator.of(context).pop();
                                                Navigator.of(context).pop();

                                                Navigator.popAndPushNamed(
                                                    context,
                                                    'admin_complaint_view',
                                                    arguments: {
                                                      "pageNumber": index,
                                                      "id": docId
                                                    });
                                              }
                                            },
                                          ),
                                        ],
                                      );
                                    });
                              },
                              child: Text(
                                'ADD UPDATES',
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 8,
                          ),
                          Expanded(
                            child: FlatButton(
                              color: Colors.red[800],
                              onPressed: () {
                                showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: Text(
                                          "Are you sure you want to change status to resolved?",
                                          style: TextStyle(
                                              fontSize: 17,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        content: Text(
                                            "This action cannot be reverted."),
                                        actions: <Widget>[
                                          RaisedButton(
                                            color: Colors.red,
                                            child: Text(
                                              "YES",
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                            onPressed: () async {
                                              showDialog(
                                                  context: context,
                                                  barrierDismissible: false,
                                                  builder: (context) {
                                                    return LoadingBox();
                                                  });
                                              var docRef = _firestore
                                                  .collection('complaints')
                                                  .document(docId);
                                              await docRef
                                                  .updateData({"status": 2});
                                              await docRef
                                                  .collection('actions')
                                                  .add({
                                                "actions": "Issue Closed",
                                                "timestamp": DateTime.now()
                                              });
                                              Navigator.pop(context);
                                              Flushbar(
                                                message:
                                                    "Status Change Successful!",
                                                duration: Duration(seconds: 1),
                                              ).show(context);
                                              await Future.delayed(Duration(
                                                  seconds: 1,
                                                  microseconds: 500));
                                              Navigator.of(context)
                                                  .pushReplacementNamed(
                                                      "adminhome");
                                            },
                                          ),
                                          RaisedButton(
                                            color: Colors.green,
                                            child: Text("NO",
                                                style: TextStyle(
                                                    color: Colors.white)),
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                        ],
                                      );
                                    });
                              },
                              child: Text(
                                'RESOLVE ISSUE',
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : Padding(
                      padding: EdgeInsets.symmetric(horizontal: 9),
                      child: RaisedButton(
                        onPressed: () {},
                        child: Text(
                          "NOTE: THIS ISSUE IS RESOLVED",
                          style: TextStyle(color: Colors.white),
                        ),
                        color: Colors.blue[800],
                      ),
                    ),
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
