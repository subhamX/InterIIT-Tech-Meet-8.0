import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:roadassist/common/common.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  PermissionStatus _permissionStatus = PermissionStatus.granted;
  PermissionGroup _permissionGroup = PermissionGroup.microphone;

  Future<void> requestPermission(PermissionGroup permission) async {
    final List<PermissionGroup> permissions = <PermissionGroup>[permission];
    final Map<PermissionGroup, PermissionStatus> permissionRequestResult =
        await PermissionHandler().requestPermissions(permissions);

    setState(() {
      _permissionStatus = permissionRequestResult[permission];
    });
  }

  Future<void> _listenForPermissionStatus() async {
    final Future<PermissionStatus> statusFuture =
        PermissionHandler().checkPermissionStatus(_permissionGroup);

    var status = await statusFuture;
    setState(() {
      _permissionStatus = status;
    });
  }

  @override
  void initState() {
    super.initState();

    _listenForPermissionStatus().then((_) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (_permissionStatus == PermissionStatus.denied) {
          await requestPermission(PermissionGroup.microphone);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Common.getAppBar(context),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 15, 0, 10),
                child: Card(
                  elevation: 0,
                  color: Theme.of(context).scaffoldBackgroundColor,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      ListTile(
                        leading: Tab(icon: Image.asset("assets/dashboard.png")),
                        title: Text(
                          "DASHBOARD",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 20),
                        ),
                        subtitle: Text('Welcome, to Road Assist!'),
                      ),
                      ButtonTheme.bar(
                        // make buttons use the appropriate styles for cards
                        child: ButtonBar(
                          children: <Widget>[
                            FlatButton(
                              child: Text('EXPLORE'),
                              onPressed: () {
                                Navigator.pushNamed(context, 'explore');
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Divider(
                height: 10,
                indent: 5,
                endIndent: 5,
                color: Colors.black,
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Tab(icon: Image.asset("assets/icons/menu.png")),
                        Text(
                          "MENU",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 16),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: FlatButton(
                            onPressed: () {
                              Navigator.pushNamed(context, "new_complaint");
                            },
                            child: Container(
                              child: Column(
                                children: <Widget>[
                                  Image.asset(
                                    'assets/icons/new-comp.png',
                                    height: 80,
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Text(
                                    'New Complaint',
                                    style: TextStyle(fontSize: 15),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: FlatButton(
                            onPressed: () {
                              Navigator.pushNamed(context, "complaint_list");
                            },
                            child: Container(
                              child: Column(
                                children: <Widget>[
                                  Image.asset(
                                    'assets/icons/list.png',
                                    height: 80,
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Text(
                                    'My Complaints',
                                    style: TextStyle(fontSize: 15),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
