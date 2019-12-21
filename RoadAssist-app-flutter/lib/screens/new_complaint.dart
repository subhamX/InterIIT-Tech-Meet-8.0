import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:roadassist/common/common.dart';
import 'dart:async';
import 'package:google_map_location_picker/google_map_location_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:roadassist/error/errorpage.dart';
import 'package:roadassist/screens/loaders/loadingbox.dart';
import 'package:firebase_storage/firebase_storage.dart';

class NewComplaint extends StatefulWidget {
  @override
  State<NewComplaint> createState() => NewComplaintState();
}

class NewComplaintState extends State<NewComplaint> {
  LocationResult _pickedLocation;
  File pickedImage;
  Firestore _firestore = Firestore.instance;
  FirebaseAuth _auth = FirebaseAuth.instance;
  bool isImageLoaded = false;
  final _key = GlobalKey<FormState>();
  final suggestionsController = TextEditingController();
  String _suggestions, _rating;
  bool showLocError = false;
  void setSuggestions(String input) {
    suggestionsController.text = input;
    _suggestions = input;
  }

  List<String> ratingOptions = Common.ratingOptions;
  Future<String> uploadFile() async {
    StorageReference storageReference = FirebaseStorage.instance
        .ref()
        .child('roadimages/${pickedImage.path.split("/").last}');
    StorageUploadTask uploadTask = storageReference.putFile(pickedImage);
    await uploadTask.onComplete;
    print('File Uploaded');
    dynamic _uploadedFileURL = await storageReference.getDownloadURL();
    print(_uploadedFileURL);
    return _uploadedFileURL;
  }

  Future<void> _submitForm() async {
    try {
      // Validating Form
      if (_pickedLocation == null) {
        _key.currentState.validate();
        setState(() {
          showLocError = true;
        });
        return;
      }
      if (_key.currentState.validate()) {
        // Showing Loading Box
        showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) {
              return LoadingBox();
            });
        _key.currentState.save();
        print(_pickedLocation.address);

        // Fetching current user instance
        FirebaseUser user = await _auth.currentUser();
        if (!user.isAnonymous) {
          String imgURL = await uploadFile();
          String uid = user.uid;
          int _ratingId = ratingOptions.indexOf(_rating);
          CollectionReference docRef = _firestore.collection('complaints');
          DocumentReference result = await docRef.add({
            "uid": uid,
            "imageurl": imgURL,
            "imagepath": "${pickedImage.path.split("/").last}",
            "suggestions": _suggestions,
            "rating": _ratingId + 1,
            "location": [
              _pickedLocation.latLng.latitude,
              _pickedLocation.latLng.longitude
            ],
            "name": "NO_NAME",
            "status": 0,
            "timestamp": DateTime.now()
          });
          await _firestore
              .collection('complaints')
              .document(result.documentID)
              .collection('actions')
              .add({"timestamp": DateTime.now(), "actions": "Issue Initiated"});
          // Poping LoadingBox
          Navigator.pop(context);
          // Poping New Complaint
          Navigator.pop(context);
        } else {
          Navigator.pushReplacementNamed(context, 'signin');
        }
      }
    } catch (onError) {
      print(onError);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ErrorPage(),
        ),
      );
    }
  }

  void pickImage() async {
    final imagesource = await showDialog<ImageSource>(
        context: context,
        builder: (context) => AlertDialog(
              title: Text("Select the image source"),
              actions: <Widget>[
                MaterialButton(
                  child: Text(
                    "Camera",
                    style: TextStyle(
                      color: Colors.blue[800],
                      fontSize: 17,
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context, ImageSource.camera);
                  },
                ),
                MaterialButton(
                  child: Text(
                    "Browse",
                    style: TextStyle(
                      color: Colors.blue[800],
                      fontSize: 17,
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context, ImageSource.gallery);
                  },
                )
              ],
            ));
    if (imagesource != null) {
      final file = await ImagePicker.pickImage(source: imagesource);
      if (file != null) {
        setState(() {
          pickedImage = file;
          isImageLoaded = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: Common.getAppBar(context),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.fromLTRB(10, 10, 10, 5),
          child: Column(children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Image.asset(
                  'assets/template-icon.png',
                  height: 55,
                ),
                SizedBox(
                  width: 8,
                ),
                Text(
                  "NEW COMPLAINT",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                ),
              ],
            ),
            Divider(
              height: 15,
              indent: 20,
              endIndent: 20,
              color: Colors.black,
            ),
            SizedBox(
              height: 5,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
              child: Align(
                alignment: Alignment.topLeft,
                child: Text(
                  "*Tap on Road Location To Mark the Location on Map",
                  style: TextStyle(
                    color: Colors.black54,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
              child: Align(
                alignment: Alignment.topLeft,
                child: Text(
                  "*Please Tap on Upload Image to Add Images",
                  style: TextStyle(
                    color: Colors.black54,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
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
            Form(
              key: _key,
              child: Column(
                children: <Widget>[
                  Container(
                      padding: EdgeInsets.fromLTRB(2, 2, 0, 2),
                      child: Column(
                        children: <Widget>[
                          ListTile(
                            onTap: () async {
                              LocationResult result =
                                  await LocationPicker.pickLocation(
                                context,
                                'API_KEY',
                              );
                              print("result = $result");
                              setState(() => _pickedLocation = result);
                            },
                            leading: Tab(
                              icon: Image.asset(
                                'assets/icons/road.png',
                                height: 35,
                              ),
                            ),
                            // color: Colors.amber[700],
                            title: Row(
                              children: <Widget>[
                                Text('Road Location'),
                                SizedBox(
                                  width: 10,
                                ),
                                _pickedLocation == null
                                    ? Tab(
                                        icon: Image.asset(
                                          'assets/icons/click.png',
                                          height: 25,
                                        ),
                                      )
                                    : Icon(
                                        Icons.done_all,
                                        color: Colors.blue[800],
                                      ),
                              ],
                            ),
                          ),
                          showLocError
                              ? Text(
                                  "Please choose a Road Location",
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 12,
                                  ),
                                )
                              : Container(),
                        ],
                      )),
                  DropdownButtonFormField(
                    validator: (input) {
                      if (input == null) {
                        return 'Please Choose A Valid Rating';
                      } else {
                        return null;
                      }
                    },
                    hint: Text("Road Rating"),
                    value: _rating,
                    items: ratingOptions.map((f) {
                      return DropdownMenuItem<dynamic>(
                        value: f,
                        child: new Text(f),
                      );
                    }).toList(),
                    onChanged: (a) {
                      setState(() {
                        _rating = a;
                      });
                    },
                  ),
                  Row(
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.fromLTRB(2, 2, 0, 2),
                        width: MediaQuery.of(context).size.width * 0.80,
                        child: TextFormField(
                          decoration: InputDecoration(
                            labelText: "Suggestions",
                          ),
                          onChanged: (input) {
                            _suggestions = input;
                          },
                          controller: suggestionsController,
                          validator: (input) {
                            if (input.length > 0) {
                              return null;
                            } else {
                              return "Please suggest something";
                            }
                          },
                        ),
                      ),
                      GestureDetector(
                        onTap: () async {
                          await Navigator.pushNamed(
                            context,
                            'listening_fetch',
                            arguments: {
                              "fieldName": "Form Name",
                              "path": "/forms/",
                              "setData": setSuggestions,
                            },
                          );
                        },
                        child: Icon(
                          Icons.mic,
                          color: Colors.black,
                          size: 30,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  GestureDetector(
                    onTap: pickImage,
                    child: Center(
                      child: Container(
                        height: MediaQuery.of(context).size.height * 0.3,
                        width: MediaQuery.of(context).size.width * 0.98,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: isImageLoaded
                                ? FileImage(pickedImage)
                                : ExactAssetImage('assets/backimg.png'),
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                ],
              ),
            )
          ]),
          // Text(_pickedLocation.toString()),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 9.0),
        child: RaisedButton(
          color: Colors.blue[800],
          onPressed: () async {
            // print(_pickedLocation.toString());
            await _submitForm();
          },
          child: Text(
            'REGISTER COMPLAINT',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
