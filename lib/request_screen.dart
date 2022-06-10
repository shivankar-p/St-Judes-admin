import 'package:admin_app/loggedIn.dart';
import 'package:admin_app/notify_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'flutter_beautiful_popup-1.7.0/lib/main.dart';
import 'upload_docs_picker.dart';

class RequestScreen extends StatefulWidget {
  @override
  _RequestScreen createState() {
    return new _RequestScreen();
  }
}

List<String> items = [
  "ey",
  "hello",
  "eyaln",
  "kk",
  "kvn",
  ",vv",
  "kakd",
  "n,dfn0",
  "lnfld"
];

class _RequestScreen extends State<RequestScreen> {
  //const WeeklyForecastList({Key? key}) : super(key: key);

  TextEditingController phoneController = TextEditingController();
  TextEditingController nameController = TextEditingController();

  Map<String, dynamic> mp = {};
  Map<String, dynamic> logs = {};
  List<int> requestLength = [];
  void _getActiverequests() async {
    DatabaseReference _testRef =
        FirebaseDatabase.instance.ref('activerequests');
    DatabaseEvent _event = await _testRef.once();

    Map<String, dynamic> tmp = {};
    tmp = _event.snapshot.value as Map<String, dynamic>;

    _testRef = FirebaseDatabase.instance.ref('uidToPhone');
    _event = await _testRef.once();
    Map<String, dynamic> contact = {};
    contact = _event.snapshot.value as Map<String, dynamic>;

    if (mounted) {
      setState(() {
        tmp.forEach((key, value) {
          if (value["state"] == 1) {
            logs[key] = value['logs'];
            mp[key] = contact[key];
          }
        });
      });
    }
  }

  int getChildCount() {
    return mp.length;
  }

  void saveLogs(String cat, String amt, String desc, String remark, String uid,
      int index) async {
    DatabaseReference _testRef =
        FirebaseDatabase.instance.ref('activerequests/' + uid);

    _testRef.child('logs').set({
      'category': cat,
      'amount': amt,
      'description': desc,
      'remarks': remark
    });
  }

  void rejectUpdate(String uid, String finalRemarks) async
  {
    DatabaseReference _testRef =
        FirebaseDatabase.instance.ref('activerequests/' + uid);
    _testRef.child("state").set(-1);
    _testRef.child("close_remarks").set(finalRemarks);

    //move to previous Requests
    DatabaseReference _prevRequests =
        FirebaseDatabase.instance.ref('requests/' + uid);
    DatabaseEvent _event = await _prevRequests.once();
    List<dynamic> tmp = [];

    DatabaseEvent recentQuery = await _testRef.once();
    if (_event.snapshot.value != null) {
      tmp = _event.snapshot.value as List<dynamic>;
      _prevRequests
          .child(tmp.length.toString())
          .set(recentQuery.snapshot.value);
    } else {
      _prevRequests = FirebaseDatabase.instance.ref('requests');
      _prevRequests
          .child(uid)
          .child("0")
          .set(recentQuery.snapshot.value);
    }
  }

  dynamic rejectRequest(String uid) {
    TextEditingController RemarkController = TextEditingController();
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              content: Stack(children: <Widget>[
            Positioned(
              right: -40.0,
              top: -40.0,
              child: InkResponse(
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: CircleAvatar(
                  child: Icon(Icons.close),
                  backgroundColor: Colors.red,
                ),
              ),
            ),
            Form(
                child:
                    Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
              Padding(
                padding: EdgeInsets.all(8.0),
                child: TextFormField(
                  decoration: const InputDecoration(
                    icon: const Icon(Icons.feedback),
                    hintText: 'Enter Request closing remarks',
                    labelText: 'Final Remarks',
                  ),
                  controller: RemarkController,
                ),
              ),
              Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: Colors.orange,
                      ),
                      child: Text("Submit"),
                      onPressed: () {
                        rejectUpdate(uid, RemarkController.text);
                        Navigator.pop(context);
                        Navigator.pushReplacement(context,
                            MaterialPageRoute(builder: (context) {
                          return LoggedInScreen();
                        }));
                      }))
            ]))
          ]));
        });
  }

  @override
  Widget build(BuildContext context) {
    BuildContext parentcontext = context;
    _getActiverequests();
    final DateTime currentDate = DateTime.now();
    final TextTheme textTheme = Theme.of(context).textTheme;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // This is the theme of your application.
      //theme: ThemeData.dark(),
      // Scrolling in Flutter behaves differently depending on the
      // ScrollBehavior. By default, ScrollBehavior changes depending
      // on the current platform. For the purposes of this scrolling
      // workshop, we're using a custom ScrollBehavior so that the
      // experience is the same for everyone - regardless of the
      // platform they are using.
      scrollBehavior: const ConstantScrollBehavior(),
      title: 'St Judes',
      home: Scaffold(
        body: Scrollbar(
            child: CustomScrollView(
          slivers: <Widget>[
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  //final Request dailyForecast = Server.getDailyForecastByID(index);
                  return Card(
                    child: Row(
                      children: <Widget>[
                        SizedBox(
                          height: 200.0,
                          width: 200.0,
                          child: Stack(
                            fit: StackFit.expand,
                            children: <Widget>[],
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  mp.values.elementAt(index)['name'],
                                  style: TextStyle(
                                      color: Colors.black, fontSize: 40),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: ElevatedButton(
                              child: const Text('Notify'),
                              onPressed: () async {
                                Navigator.push(context,
                                    MaterialPageRoute(builder: (parentcontext) {
                                  return ChatRoom(mp.keys.elementAt(index),
                                      mp.values.elementAt(index)['name']);
                                }));
                              }),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: ElevatedButton(
                              child: const Text('Reject'),
                              onPressed: () async {
                                rejectRequest(mp.keys.elementAt(index));
                              }),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: ElevatedButton(
                              child: const Text('Applicant logs'),
                              onPressed: () {
                                TextEditingController catController =
                                    TextEditingController();
                                TextEditingController amtController =
                                    TextEditingController();
                                TextEditingController descController =
                                    TextEditingController();
                                TextEditingController remarkController =
                                    TextEditingController();

                                catController.text =
                                    logs[mp.keys.elementAt(index)]['category'];
                                amtController.text =
                                    logs[mp.keys.elementAt(index)]['amount'];
                                descController.text =
                                    logs[mp.keys.elementAt(index)]
                                        ['description'];
                                remarkController.text =
                                    logs[mp.keys.elementAt(index)]['remarks'];

                                final popup = BeautifulPopup(
                                  context: context,
                                  template: TemplateTerm,
                                );

                                popup.show(
                                  title: mp.values.elementAt(index)['name'] +
                                      '\'s request logs',
                                  content: Scrollbar(
                                      child: SingleChildScrollView(
                                          child: Form(
                                              child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: <Widget>[
                                        TextFormField(
                                          decoration: const InputDecoration(
                                            icon: const Icon(Icons.category),
                                            hintText: 'Request Category',
                                            labelText: 'Category',
                                          ),
                                          controller: catController,
                                        ),
                                        TextFormField(
                                            decoration: const InputDecoration(
                                              icon: const Icon(
                                                  Icons.currency_rupee),
                                              hintText: 'Requested amount',
                                              labelText: 'Amount',
                                            ),
                                            controller: amtController,
                                            keyboardType: TextInputType.number),
                                        TextFormField(
                                          decoration: const InputDecoration(
                                            icon: const Icon(Icons.description),
                                            hintText: 'Description',
                                            labelText: 'Request Description',
                                          ),
                                          controller: descController,
                                          maxLines: null,
                                        ),
                                        TextFormField(
                                          decoration: const InputDecoration(
                                            icon: const Icon(Icons.feedback),
                                            hintText: 'Remarks',
                                            labelText: 'Admin remarks',
                                          ),
                                          controller: remarkController,
                                          maxLines: null,
                                        )
                                      ])))),
                                  close: Text(''),
                                  barrierDismissible: true,
                                  actions: [
                                    popup.button(
                                      label: 'Save',
                                      onPressed: () {
                                        /* Navigator.pop(context);
                                          RequestScreen(); */
                                        saveLogs(
                                            catController.text,
                                            amtController.text,
                                            descController.text,
                                            remarkController.text,
                                            mp.keys.elementAt(index),
                                            index);
                                      },
                                    ),
                                    popup.button(
                                      label: 'Move to upload stage',
                                      onPressed: () {
                                        saveLogs(
                                            catController.text,
                                            amtController.text,
                                            descController.text,
                                            remarkController.text,
                                            mp.keys.elementAt(index),
                                            index);

                                        Navigator.push(context,
                                            MaterialPageRoute(
                                                builder: (parentcontext) {
                                          return docPicker(
                                              mp.keys.elementAt(index));
                                        }));
                                      },
                                    ),
                                  ],
                                  // bool barrierDismissible = false,
                                  // Widget close,
                                );
                              }),
                        ),
                      ],
                    ),
                  );
                },
                childCount: getChildCount(),
              ),
            )
          ],
        )),
      ),
    );
  }
}

// --------------------------------------------
// Below this line are helper classes and data.

const String baseAssetURL =
    'https://dartpad-workshops-io2021.web.app/getting_started_with_slivers/';
const String headerImage = '${baseAssetURL}assets/header.jpeg';

class ConstantScrollBehavior extends ScrollBehavior {
  const ConstantScrollBehavior();

  @override
  Widget buildScrollbar(
          BuildContext context, Widget child, ScrollableDetails details) =>
      child;

  @override
  Widget buildOverscrollIndicator(
          BuildContext context, Widget child, ScrollableDetails details) =>
      child;

  @override
  TargetPlatform getPlatform(BuildContext context) => TargetPlatform.macOS;

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) =>
      const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics());
}
