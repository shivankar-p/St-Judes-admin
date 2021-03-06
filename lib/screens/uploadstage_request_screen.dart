import 'package:admin_app/screens/loggedIn.dart';
import 'package:admin_app/screens/notify_screen.dart';
import 'package:admin_app/screens/verifydocs_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../flutter_beautiful_popup-1.7.0/lib/main.dart';
import '../utils/upload_docs_picker.dart';
import '../utils/audio.dart';
import 'package:intl/intl.dart';
import '../widget/search_widget.dart';
import '../api/translation_api.dart';
import 'package:intl/intl.dart';

class Constants {
  static const String inc = 'Least no of requests';
  static const String Date = 'Request Date';
  static const String dec = 'Most no of requests';

  static const List<String> choices = <String>[inc, Date, dec];
}

class UploadStageScreen extends StatefulWidget {
  @override
  _UploadStageScreen createState() {
    return new _UploadStageScreen();
  }
}

class _UploadStageScreen extends State<UploadStageScreen> {
  //const WeeklyForecastList({Key? key}) : super(key: key);

  TextEditingController phoneController = TextEditingController();
  TextEditingController nameController = TextEditingController();

  Map<String, dynamic> mp = {};
  Map<String, dynamic> logs = {};
  Map<String, dynamic> activeRequests = {};
  Map<String, dynamic> audiofiles = {};
  List<int> requestLength = [];
  List<String> prevrequestLength = List.filled(100000, '0');
  String query = '';
  bool isSorted = false;

  Widget buildSearch() => SearchWidget(
        text: query,
        hintText: 'ID or User name or Language',
        onChanged: searchUser,
      );

  void searchUser(String str) async {
    str = str.toLowerCase();

    DatabaseReference _testRef =
        FirebaseDatabase.instance.ref('activerequests');
    DatabaseEvent _event = await _testRef.once();

    Map<String, dynamic> tmp1 = {};
    activeRequests = _event.snapshot.value as Map<String, dynamic>;
    tmp1 = _event.snapshot.value as Map<String, dynamic>;

    setState(() {
      query = str;
    });

    Map<String, dynamic> tmp = {};

    mp.forEach((k, v) {
      String name = v["name"];
      name = name.toLowerCase();

      String language = tmp1[k]["language"];
      language = language.toLowerCase();

      if (k.contains(query) ||
          name.contains(query) ||
          query.contains(language)) {
        tmp[k] = v;
      }
    });

    setState(() {
      mp = tmp;
    });
  }

  void _getActiverequests() async {
    if (query.isEmpty) {
      DatabaseReference _testRef =
          FirebaseDatabase.instance.ref('activerequests');
      DatabaseEvent _event = await _testRef.once();

      Map<String, dynamic> tmp = {};
      activeRequests = _event.snapshot.value as Map<String, dynamic>;
      tmp = _event.snapshot.value as Map<String, dynamic>;

      _testRef = FirebaseDatabase.instance.ref('uidToPhone');
      _event = await _testRef.once();
      Map<String, dynamic> contact = {};
      contact = _event.snapshot.value as Map<String, dynamic>;

      if (mounted) {
        setState(() {
          tmp.forEach((key, value) {
            if (value["state"] == 2 || value["state"] == 3) {
              logs[key] = value['logs'];
              mp[key] = contact[key];
              audiofiles[key] = value['voice'];
            }
          });
        });

        int cnt = 0;
        mp.forEach((key, value) async {
          DatabaseReference _testRef =
              FirebaseDatabase.instance.ref('requests/' + key);
          DatabaseEvent _event = await _testRef.once();
          if (_event.snapshot.value != null) {
            List<dynamic> lst = _event.snapshot.value as List<dynamic>;
            if (mounted) {
              setState(() {
                prevrequestLength[cnt] = lst.length.toString();
              });
            }
          }
          cnt++;
        });
      }
    }
  }

  int getChildCount() {
    return mp.length;
  }

  void saveLogs(String cat, String amt, String desc, String remark, String uid,
      int index) async {
    DatabaseReference _testRef =
        FirebaseDatabase.instance.ref('activerequests/' + uid);

    String date = DateFormat("dd MMMM yyyy").format(DateTime.now());
    String time = DateFormat("HH:mm:ss").format(DateTime.now());

    _testRef.child('logs').set({
      'category': cat,
      'amount': amt,
      'description': desc + '  \n-' + date + ',  ' + time,
      'remarks': remark
    });
  }

  void rejectUpdate(String uid, String finalRemarks) async {
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
      _prevRequests.child(uid).child("0").set(recentQuery.snapshot.value);
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
                        notify_user(
                            uid,
                            "Request Rejected:Your request has been rejected. Admin remarks:" +
                                RemarkController.text);
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

  void choiceAction(String choice) {
    if (choice == Constants.inc) {
      this.isSorted = !this.isSorted;
    }
  }

  void notify_user(uid, msg) async {
    String date = DateFormat("dd MMMM yyyy").format(DateTime.now());
    String time = DateFormat("HH:mm:ss").format(DateTime.now());

    DatabaseReference _testRef =
        FirebaseDatabase.instance.ref('notifications/' + uid);
    DatabaseEvent _event = await _testRef.once();

    DatabaseReference _langRef =
        FirebaseDatabase.instance.ref('uidToPhone/' + uid + '/language');
    DatabaseEvent _lang = await _langRef.once();

    String lang = _lang.snapshot.value as String;

    TranslationApi translator = TranslationApi();

    String translated_msg = await translator.translate(msg, 'en', lang);

    if (_event.snapshot.value != null)
      _testRef.push().set({
        'date': date,
        'msg': translated_msg,
        'time': time,
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
      scrollBehavior: const ConstantScrollBehavior(),
      title: 'St Judes',
      home: Scaffold(
        body: Scrollbar(
            child: CustomScrollView(
          slivers: <Widget>[
            SliverToBoxAdapter(
              child: Row(children: [
                buildSearch(),
                PopupMenuButton<String>(
                  icon: Icon(Icons.sort),
                  onSelected: choiceAction,
                  itemBuilder: (BuildContext context) {
                    return Constants.choices.map((String choice) {
                      return PopupMenuItem<String>(
                        value: choice,
                        child: Text(choice),
                      );
                    }).toList();
                  },
                )
              ]),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  //final Request dailyForecast = Server.getDailyForecastByID(index);
                  TextEditingController phCnt = TextEditingController();
                  TextEditingController uidCnt = TextEditingController();
                  TextEditingController noCnt = TextEditingController();
                  TextEditingController langCnt = TextEditingController();
                  phCnt.text = mp.values.elementAt(index)['phone'];
                  uidCnt.text = mp.keys.elementAt(index);
                  noCnt.text = prevrequestLength[index];
                  langCnt.text =
                      activeRequests[mp.keys.elementAt(index)]['language'];
                  return ExpansionTile(
                    children: [
                      Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                                width: 200,
                                child: TextFormField(
                                  enabled: false,
                                  decoration: InputDecoration(
                                      contentPadding:
                                          EdgeInsets.fromLTRB(10, 5, 5, 5),
                                      icon: Icon(Icons.phone),
                                      labelText: 'Phone'),
                                  controller: phCnt,
                                )),
                            Container(
                                width: 200,
                                padding: EdgeInsets.only(left: 30),
                                child: TextFormField(
                                  enabled: false,
                                  decoration: InputDecoration(
                                      contentPadding:
                                          EdgeInsets.fromLTRB(10, 5, 5, 5),
                                      icon: Icon(Icons.key),
                                      labelText: 'UID'),
                                  controller: uidCnt,
                                )),
                            Container(
                                width: 200,
                                padding: EdgeInsets.only(left: 30),
                                child: TextFormField(
                                  enabled: false,
                                  decoration: InputDecoration(
                                      contentPadding:
                                          EdgeInsets.fromLTRB(10, 5, 5, 5),
                                      icon: Icon(Icons.numbers),
                                      labelText: 'Number of request raised'),
                                  controller: noCnt,
                                )),
                            Container(
                                width: 200,
                                padding: EdgeInsets.only(left: 30),
                                child: TextFormField(
                                  enabled: false,
                                  decoration: InputDecoration(
                                      contentPadding:
                                          EdgeInsets.fromLTRB(5, 5, 5, 5),
                                      icon: Icon(Icons.language),
                                      labelText: 'Language'),
                                  controller: langCnt,
                                )),
                            if (audiofiles[mp.keys.elementAt(index)] != '')
                              audio(audiofiles[mp.keys.elementAt(index)])
                            else
                              Padding(
                                  padding: EdgeInsets.fromLTRB(100, 5, 5, 5),
                                  child: Text('No Voicenote Uploaded',
                                      style: TextStyle(
                                          fontSize: 20, color: Colors.grey)))
                          ])
                    ],
                    title: Row(
                      children: <Widget>[
                        SizedBox(
                          height: 100.0,
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
                              child: const Text('Reject'),
                              style: ElevatedButton.styleFrom(
                                primary: Colors.red,
                              ),
                              onPressed: () async {
                                rejectRequest(mp.keys.elementAt(index));
                              }),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: ElevatedButton(
                              child: const Text('Notify'),
                              style: ElevatedButton.styleFrom(
                                primary: Colors.orange,
                              ),
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
                                  ],
                                  // bool barrierDismissible = false,
                                  // Widget close,
                                );
                              }),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: ElevatedButton(
                              child: const Text('Verify Documents'),
                              style: ElevatedButton.styleFrom(
                                primary: Colors.green,
                              ),
                              onPressed: () async {
                                Navigator.push(context,
                                    MaterialPageRoute(builder: (context) {
                                  return verifyScreen(mp.keys.elementAt(index));
                                }));
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
