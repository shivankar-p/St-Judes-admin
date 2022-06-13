import 'package:admin_app/screens/loggedIn.dart';
import 'package:admin_app/screens/notify_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../flutter_beautiful_popup-1.7.0/lib/main.dart';
import '../utils/upload_docs_picker.dart';
import '../widget/search_widget.dart';
import 'dart:html' as html;
import '../api/translation_api.dart';
import 'package:intl/intl.dart';

class CounsellingScreen extends StatefulWidget {
  @override
  _CounsellingScreen createState() {
    return new _CounsellingScreen();
  }
}

class _CounsellingScreen extends State<CounsellingScreen> {
  //const WeeklyForecastList({Key? key}) : super(key: key);
  Map<String, dynamic> mp = {};
  Map<String, dynamic> mp2 = {};

  String query = '';

  Widget buildSearch() => SearchWidget(
        text: query,
        hintText: 'ID or User name',
        onChanged: searchUser,
      );

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

  void searchUser(String str) {
    //print("Searching User\n\n");
    str = str.toLowerCase();

    setState(() {
      query = str;
    });

    Map<String, dynamic> tmp = {};

    mp.forEach((k, v) {
      String name = v["name"];
      name = name.toLowerCase();

      if (k.contains(query) || name.contains(query)) {
        tmp[k] = v;
      }
    });

    //print(tmp);

    setState(() {
      mp = tmp;
    });

    //print(mp);
    //print("before");
  }

  void _getQueries() async {
    print('not empty');
    if (query.isEmpty) {
      print('empty');
      DatabaseReference _testRef = FirebaseDatabase.instance.ref('counselling');
      DatabaseEvent _event = await _testRef.once();
      mp = _event.snapshot.value as Map<String, dynamic>;
      print(mp['12345']);
    }
  }

  void updateCounselling(uid, date, time, link) {
    DatabaseReference _testRef =
        FirebaseDatabase.instance.ref('counselling/' + uid);
    _testRef.child('link').set(link);
    _testRef.child('date').set(date);
    _testRef.child('time').set(time);
    _testRef.child('state').set(2);
  }

  Future getphone(uid) async {
    DatabaseReference _testRef =
        FirebaseDatabase.instance.ref('uidToPhone/' + uid);
    DatabaseEvent _event = await _testRef.once();
    var phone = _event.snapshot.value as Map<String, dynamic>;
    return phone['phone'];
  }

  Future getname(uid) async {
    DatabaseReference _testRef =
        FirebaseDatabase.instance.ref('uidToPhone/' + uid);
    DatabaseEvent _event = await _testRef.once();
    var phone = _event.snapshot.value as Map<String, dynamic>;
    return phone['name'];
  }

  int getChildCount() {
    return mp.length;
  }

  void openlink(url) {
    html.window.open(url, "_blank");
  }

  dynamic getpopup(String uid) {
    TextEditingController timeController = TextEditingController();
    TextEditingController linkController = TextEditingController();
    TextEditingController dateController = TextEditingController();
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
                    icon: const Icon(Icons.link),
                    hintText: 'Enter meeting url',
                    labelText: 'Link',
                  ),
                  controller: linkController,
                ),
              ),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: TextFormField(
                  decoration: const InputDecoration(
                    icon: const Icon(Icons.watch),
                    hintText: 'Meeting time',
                    labelText: 'Time',
                  ),
                  controller: timeController,
                ),
              ),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: TextFormField(
                  decoration: const InputDecoration(
                    icon: const Icon(Icons.date_range),
                    hintText: 'date',
                    labelText: 'Date',
                  ),
                  controller: dateController,
                ),
              ),
              Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: Colors.orange,
                      ),
                      child: Text("Done"),
                      onPressed: () {
                        updateCounselling(uid, dateController.text,
                            timeController.text, linkController.text);
                        notify_user(
                            uid,
                            "Counselling: You have a counselling session on " +
                                dateController.text +
                                " at " +
                                timeController.text +
                                " \n" +
                                "Please join with the following link-\n" +
                                linkController.text);
                        Navigator.pop(context);
                      }))
            ]))
          ]));
        });
  }

  @override
  Widget build(BuildContext context) {
    //BuildContext parentcontext = context;
    _getQueries();
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      scrollBehavior: const ConstantScrollBehavior(),
      title: 'St Judes',
      home: Scaffold(
        body: Scrollbar(
            child: CustomScrollView(
          slivers: <Widget>[
            SliverToBoxAdapter(
              child: buildSearch(),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  //final Request dailyForecast = Server.getDailyForecastByID(index);

                  TextEditingController linkCnt = TextEditingController();
                  TextEditingController timeCnt = TextEditingController();
                  TextEditingController uidCnt = TextEditingController();
                  var name = getname(mp.keys.elementAt(index));
                  linkCnt.text = mp.values.elementAt(index)['link'];
                  timeCnt.text = mp.values.elementAt(index)['date'] +
                      '  ' +
                      mp.values.elementAt(index)['time'];
                  uidCnt.text = mp.keys.elementAt(index);

                  return ExpansionTile(
                    textColor: Colors.black,
                    title: Padding(
                        padding: EdgeInsets.fromLTRB(5, 20, 5, 20),
                        child: FutureBuilder(
                          future: name,
                          builder: (context, snapshot) {
                            if (snapshot.hasError) {
                              print(
                                  'There is an error ${snapshot.error.toString()}');
                              return Text('Something went wrong');
                            } else if (snapshot.hasData) {
                              //return LoggedInScreen();
                              return Text(snapshot.data.toString(),
                                  style: TextStyle(fontSize: 25));
                            } else {
                              return CircularProgressIndicator();
                            }
                          },
                        )),
                    leading: FutureBuilder(
                      future: name,
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          print(
                              'There is an error ${snapshot.error.toString()}');
                          return Text('Something went wrong');
                        } else if (snapshot.hasData) {
                          return CircleAvatar(
                            child: Text(
                                snapshot.data.toString()[0] +
                                    snapshot.data.toString()[1],
                                style: TextStyle(color: Colors.black)),
                            radius: 70,
                            backgroundColor: Colors.orange.shade200,
                          );
                        } else {
                          return CircularProgressIndicator();
                        }
                      },
                    ),
                    trailing: mp.values.elementAt(index)['state'] == 1
                        ? (ElevatedButton(
                            child: const Text('Accept'),
                            style: ElevatedButton.styleFrom(
                              minimumSize: Size(90, 60),
                              primary: Colors.orange,
                            ),
                            onPressed: () async {
                              getpopup(mp.keys.elementAt(index));
                            },
                          ))
                        : (ElevatedButton(
                            child: const Text('Join'),
                            style: ElevatedButton.styleFrom(
                              minimumSize: Size(90, 60),
                              primary: Colors.green,
                            ),
                            onPressed: () async {
                              print(linkCnt.text);
                              openlink(linkCnt.text);
                            },
                          )),
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
                                      icon: Icon(Icons.key),
                                      labelText: 'UID'),
                                  controller: uidCnt,
                                )),
                            Container(
                                width: 500,
                                child: TextFormField(
                                  enabled: false,
                                  decoration: InputDecoration(
                                      contentPadding:
                                          EdgeInsets.fromLTRB(10, 5, 5, 5),
                                      icon: Icon(Icons.link),
                                      labelText: 'Meet Link'),
                                  controller: linkCnt,
                                )),
                            Container(
                                width: 400,
                                child: TextFormField(
                                  enabled: false,
                                  decoration: InputDecoration(
                                      contentPadding:
                                          EdgeInsets.fromLTRB(10, 5, 5, 5),
                                      icon: Icon(Icons.watch),
                                      labelText: 'Date and Time'),
                                  controller: timeCnt,
                                )),
                          ])
                    ],
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
