import 'package:admin_app/loggedIn.dart';
import 'package:admin_app/notify_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'flutter_beautiful_popup-1.7.0/lib/main.dart';


class RequestScreen extends StatefulWidget {
  @override
  _RequestScreen createState() {
    return new _RequestScreen();
  }
}

List<String> items = ["ey", "hello", "eyaln", "kk", "kvn", ",vv", "kakd", "n,dfn0", "lnfld"];

class _RequestScreen extends State<RequestScreen> {
  //const WeeklyForecastList({Key? key}) : super(key: key);

  TextEditingController phoneController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  Map<String, dynamic> mp = {};
  void _getActiverequests() async {
    DatabaseReference _testRef = FirebaseDatabase.instance.ref('uidToPhone');
    Query query = _testRef.orderByChild("request").equalTo(1);
    DataSnapshot event = await query.get();
    setState(() {
      if (event.value != null) {
        mp = event.value as Map<String, dynamic>;
        /* mp.keys.forEach((element) {
        print(mp[element]['name']);
      }); */
      }
    });
    //print(mp.values.elementAt(0)['name']);
  }

  int getChildCount() {
    return mp.length;
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
      theme: ThemeData.dark(),
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
                                      color: Colors.white, fontSize: 40),
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
                              child: const Text('Applicant logs'),
                              onPressed: () {
                                final popup = BeautifulPopup(
                                  context: context,
                                  template: TemplateTerm,
                                );
                                
                                popup.show(
                                  title: mp.values.elementAt(index)['name'] +
                                      '\'s request logs',
                                  content: Scrollbar(
                                      child: SingleChildScrollView(
                                      child:    Form(  
                                                child: Column(  
                                                  crossAxisAlignment: CrossAxisAlignment.start,  
                                                  children: <Widget>[ 
                                                    TextFormField(  
                                                      decoration: const InputDecoration(  
                                                        icon: const Icon(Icons.category),  
                                                        hintText: 'Request Category',  
                                                        labelText: 'Category',  
                                                      ),  
                                                    ),  
                                                    TextFormField(  
                                                      decoration: const InputDecoration(  
                                                        icon: const Icon(Icons.currency_rupee),  
                                                        hintText: 'Requested amount',  
                                                        labelText: 'Amount',  
                                                      ),  
                                                      keyboardType: TextInputType.number
                                                    ),  
                                                    TextFormField(  
                                                      decoration: const InputDecoration(  
                                                      icon: const Icon(Icons.description),  
                                                      hintText: 'Description',  
                                                      labelText: 'Request Description',  
                                                      ),
                                                      maxLines: null,  
                                                     ),
                                                     TextFormField(  
                                                      decoration: const InputDecoration(  
                                                      icon: const Icon(Icons.feedback),  
                                                      hintText: 'Remarks',  
                                                      labelText: 'Admin remarks',  
                                                      ),
                                                      maxLines: null,  
                                                     )]
                                                     )
                      ))),  
                                  close: Text(''),
                                  barrierDismissible: true,
                                  actions: [
                                    popup.button(
                                        label: 'Close',
                                        onPressed: () {
                                          /* Navigator.pop(context);
                                          RequestScreen(); */
                                          Navigator.pushReplacement(context,
                                    MaterialPageRoute(builder: (parentcontext) {
                                  return LoggedInScreen();
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
