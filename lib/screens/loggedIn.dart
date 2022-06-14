import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'request_screen.dart';
import 'notify_screen.dart';
import 'uploadstage_request_screen.dart';
import 'queries.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'counselling.dart';
import '../api/translation_api.dart';
import '../main.dart';
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

    _tabController = TabController(vsync: this, initialIndex: 0, length: 4);
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
        title: Row(
              children: [
                  Image.asset(
                 'assets/images/logo_black.png',
                  fit: BoxFit.contain,
                  height: 32,
              ),
              Container(
                  padding: const EdgeInsets.all(8.0), child: Text('St Judes for Life'))
            ],

          ),
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
            Tab(
              text: "Counselling",
            ),
          ],
        ),
        actions: <Widget>[
           Padding(
            padding: EdgeInsets.only(right: 20.0),
            child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        child: Icon(
                          Icons.dashboard,
                          size: 26,
                          ),
                        onTap: () {
                          Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => MyApp()),
                              (Route<dynamic> route) => false,
                              );
                        },
                      ),
                  ),
          ),
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
          QueriesScreen(),
          CounsellingScreen()
          //QueriesScreen()
        ],
      ),
    );
  }
}
