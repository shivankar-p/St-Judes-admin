import 'package:admin_app/screens/uploadstage_request_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:bubble/bubble.dart';
import 'dart:math';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'package:firebase_database/firebase_database.dart';
import '../screens/request_screen.dart';
import '../screens/loggedIn.dart';

class docPicker extends StatefulWidget {
  String uid;
  int flag;
  docPicker(this.uid, this.flag);
  @override
  _docPicker createState() => _docPicker();
}

List<String> docs = [
  "Aadhar Card",
  "PAN Card",
  "Birth Certificate",
  "Passport",
  "Passport Size photograph",
  "Driving License",
  "Caste Certificate",
  "Voter ID card",
  "Secondary School Certificate/10th",
  "10th Class marksheet",
  "12th class marksheet",
  "Bonafide",
  "School progress/grade report",
  "Medical Prescription",
  "Diagnosis Reports"
];

List<String> dockeys = [
  "aadhar",
  "pan",
  "birth",
  "Passport",
  "photo",
  "license",
  "caste",
  "voter",
  "ssc",
  "10th",
  "12th",
  "bonafide",
  "reportcard",
  "prescription",
  "medical_report"
];

class _docPicker extends State<docPicker> {
  List<bool> docChoosen = List.filled(docs.length, false);

  int getindex(index) {
    int cnt = 0;
    int ans = 0;
    dockeys.forEach((element) {
      if (element == index) ans = cnt;
      cnt++;
    });
    return ans;
  }

  void updateDocChoosen() async {
    DatabaseReference _testRef =
        FirebaseDatabase.instance.ref('activerequests/' + widget.uid + '/docs');
    DatabaseEvent event = await _testRef.once();

    if (event.snapshot.value != null) {
      Map<String, dynamic> mp = event.snapshot.value as Map<String, dynamic>;
      mp.forEach((key, value) {
        if (mounted) {
          setState(() {
            docChoosen[getindex(key)] = true;
          });
        }
      });
    }
  }

  void updateToUploadStage() async {
    DatabaseReference _testRef =
        FirebaseDatabase.instance.ref('activerequests/' + widget.uid);

    for (var i = 0; i < docChoosen.length; i++) {
      if (docChoosen[i] == true) {
        DatabaseReference _docRef = FirebaseDatabase.instance
            .ref('activerequests/' + widget.uid + '/docs/' + dockeys[i]);
        DatabaseEvent docevent = await _docRef.once();
        if (docevent.snapshot.value == null) {
          _testRef.child('docs').child(dockeys[i]).set({"state": 0, "url": ""});
        }
      }
    }

    _testRef.child('state').set(2);
  }

  Widget build(BuildContext context) {
    if (widget.flag == 1) {
      updateDocChoosen();
    }

    return Scaffold(
        appBar: AppBar(
          title: Text('Document Picker'),
          backgroundColor: Colors.purple,
        ),
        backgroundColor: Color.fromRGBO(255, 224, 178, 1),
        body: CupertinoScrollbar(
          thickness: 10,
          thicknessWhileDragging: 10,
          child: ListView.builder(
            itemBuilder: (context, index) {
              return Material(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CheckboxListTile(
                    autofocus: false,
                    activeColor: Colors.orange,
                    checkColor: Colors.black,
                    selected: docChoosen[index],
                    value: docChoosen[index],
                    contentPadding: EdgeInsets.fromLTRB(300, 5, 300, 5),
                    title: Text(
                      docs[index],
                      style: TextStyle(fontSize: 25),
                    ),
                    onChanged: (bool? value) {
                      setState(() {
                        docChoosen[index] = value!;
                      });
                    },
                  ),
                  index == docs.length - 1
                      ? Padding(
                          padding: EdgeInsets.all(10),
                          child: ElevatedButton(
                              child: const Text(
                                'Done',
                                style: TextStyle(fontSize: 23),
                              ),
                              style: ElevatedButton.styleFrom(
                                minimumSize: Size(90, 60),
                                primary: Colors.purple,
                              ),
                              onPressed: () async {
                                updateToUploadStage();
                                if (widget.flag == 0) {
                                  Navigator.pushReplacement(context,
                                      MaterialPageRoute(builder: (context) {
                                    return RequestScreen();
                                  }));
                                } else {
                                  Navigator.pop(context, true);
                                }
                              }))
                      : Text(''),
                  Divider(
                    height: 3,
                  )
                ],
              ));
            },
            itemCount: docs.length,
          ),
          isAlwaysShown: true,
        ));
  }
}
