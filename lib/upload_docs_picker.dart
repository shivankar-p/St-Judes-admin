import 'package:admin_app/uploadstage_request_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:bubble/bubble.dart';
import 'dart:math';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'package:firebase_database/firebase_database.dart';
import 'request_screen.dart';

class docPicker extends StatefulWidget {
  String uid;
  docPicker(this.uid);
  @override
  _docPicker createState() => _docPicker();
}

List<String> docs = [
  "Aadhar Card",
  "PAN Card",
  "Birth Certificate",
  "Passport",
  "Passport Size photograph"
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

class _docPicker extends State<docPicker> {
  List<bool> docChoosen = List.filled(docs.length, false);

  void updateToUploadStage() {
    DatabaseReference _testRef =
        FirebaseDatabase.instance.ref('activerequests/' + widget.uid);
    _testRef.child('state').set(2);

    for (var i = 0; i < docChoosen.length; i++) {
      if (docChoosen[i] == true) {
        _testRef.child('docs').child(i.toString()).set({"state": 0, "url": ""});
      }
    }
  }

  Widget build(BuildContext context) {
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
                                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
                                  return RequestScreen();
                                }));
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
