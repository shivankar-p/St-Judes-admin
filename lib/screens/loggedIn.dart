import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'request_screen.dart';
import 'notify_screen.dart';
import 'uploadstage_request_screen.dart';
import 'queries.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';

class LoggedInScreen extends StatefulWidget {
  @override
  _LoggedInScreenState createState() => _LoggedInScreenState();
}

class Constants {
  static const String Remind = 'Remind document upload';

  static const List<String> choices = <String>[Remind];
}

class _LoggedInScreenState extends State<LoggedInScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool showFab = true;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(vsync: this, initialIndex: 0, length: 3);
    _tabController.addListener(() {
      showFab = true;
      setState(() {});
    });
  }

  void _sendNotification(String uid, String msg) async {
    String date = DateFormat("dd MMMM yyyy").format(DateTime.now());
    String time = DateFormat("HH:mm:ss").format(DateTime.now());

    DatabaseReference _testRef =
        FirebaseDatabase.instance.ref('notifications/' + uid);
    DatabaseEvent _event = await _testRef.once();

    List<dynamic> chatMsgs = [];
    if (_event.snapshot.value != null)
      chatMsgs = _event.snapshot.value as List<dynamic>;
    _testRef.child(chatMsgs.length.toString()).set({
      'date': date,
      'msg': msg,
      'time': time,
    });
  }

  void remindusers() async {
    DatabaseReference _testRef =
        FirebaseDatabase.instance.ref('activerequests');
    DatabaseEvent _event = await _testRef.once();

    Map<String, dynamic> tmp = {};
    tmp = _event.snapshot.value as Map<String, dynamic>;

    tmp.forEach((key, value) {
      if (value["state"] == 2) {
        String msg = "Reminder:Please upload the requested documents!";
        _sendNotification(key, msg);
      }
    });
  }

  void choiceAction(String choice) {
    if (choice == Constants.Remind) {
      remindusers();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("St Judes"),
        elevation: 0.7,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.black,
          indicatorWeight: 5.0,
          indicatorSize: TabBarIndicatorSize.label,
          tabs: <Widget>[
            Tab(
              text: "Initial Requests",
            ),
            Tab(
              text: "Upload stage Requests",
            ),
            Tab(
              text: "Queries",
            ),
          ],
        ),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5.0),
          ),
          PopupMenuButton<String>(
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
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: <Widget>[
          RequestScreen(),
          UploadStageScreen(),
          QueriesScreen()
        ],
      ),
    );
  }
}
