import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'loggedIn.dart';
import 'final_remark_popup.dart';
import 'audio.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  final Future<FirebaseApp> _fbapp = Firebase.initializeApp();
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.orange,
      ),
      home: FutureBuilder(
        future: _fbapp,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            print('There is an error ${snapshot.error.toString()}');
            return Text('Something went wrong');
          } else if (snapshot.hasData) {
            //return LoggedInScreen();
            return LoggedInScreen();
            //return audio();
          } else {
            return CircularProgressIndicator();
          }
        },
      ),
    );
  }
}
