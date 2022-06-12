import 'package:admin_app/screens/loggedIn.dart';
import 'package:admin_app/screens/notify_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../flutter_beautiful_popup-1.7.0/lib/main.dart';
import '../utils/upload_docs_picker.dart';
import '../widget/search_widget.dart';

class QueriesScreen extends StatefulWidget {
  @override
  _QueriesScreen createState() {
    return new _QueriesScreen();
  }
}

class _QueriesScreen extends State<QueriesScreen> {
  //const WeeklyForecastList({Key? key}) : super(key: key);
  Map<String, dynamic> mp = {};
  Map<String, dynamic> mp2 = {};

  String query = '';

  Widget buildSearch() => SearchWidget(
        text: query,
        hintText: 'ID or User name',
        onChanged: searchUser,
      );

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
    if (query.isEmpty) {
      DatabaseReference _testRef = FirebaseDatabase.instance.ref('queries');
      DatabaseEvent _event = await _testRef.once();
      mp = _event.snapshot.value as Map<String, dynamic>;
    }
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

                  TextEditingController phCnt = TextEditingController();
                  TextEditingController uidCnt = TextEditingController();
                  var name = getname(mp.values.elementAt(index)['uid']);
                  var phone = getphone(mp.values.elementAt(index)['uid']);
                  uidCnt.text = mp.values.elementAt(index)['uid'];

                  return ExpansionTile(
                    textColor: Colors.black,
                    title: FutureBuilder(
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
                    ),
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
                    subtitle: Text(mp.values.elementAt(index)['msg']),
                    trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                      Text(mp.values.elementAt(index)['date'] +
                          '      ' +
                          mp.values.elementAt(index)['time']),
                      Icon(Icons.arrow_drop_down_sharp),
                    ]),
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
                                width: 200,
                                child: FutureBuilder(
                                    future: phone,
                                    builder: (context, snapshot) {
                                      if (snapshot.hasError) {
                                        print(
                                            'There is an error ${snapshot.error.toString()}');
                                        return Text('Something went wrong');
                                      } else if (snapshot.hasData) {
                                        phCnt.text = snapshot.data.toString();
                                        return TextFormField(
                                          enabled: false,
                                          decoration: InputDecoration(
                                              contentPadding:
                                                  EdgeInsets.fromLTRB(
                                                      10, 5, 5, 5),
                                              icon: Icon(Icons.phone),
                                              labelText: 'Phone'),
                                          controller: phCnt,
                                        );
                                      } else {
                                        return CircularProgressIndicator();
                                      }
                                    })),
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
