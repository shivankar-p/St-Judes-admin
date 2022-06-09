import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:bubble/bubble.dart';
import 'dart:math';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'package:firebase_database/firebase_database.dart';
import 'request_screen.dart';
import 'dart:ui';
import 'uploadstage_request_screen.dart';

class verifyScreen extends StatefulWidget {
  String uid;
  verifyScreen(this.uid);
  @override
  _verifyScreen createState() => _verifyScreen();
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

Map<String, int> docname = {
  "aadhar": 0,
  "pan": 1,
  "birth": 2,
  "Passport": 3,
  "photo": 4,
  "license": 5,
  "caste": 6,
  "voter": 7,
  "ssc": 8,
  "10th": 9,
  "12th": 10,
  "bonafide": 11,
  "reportcard": 12,
  "prescription": 13,
  "medical_report": 14
};

class _verifyScreen extends State<verifyScreen> {
  Map<String, dynamic> requestedDocs = {};
  int verifiedDocCount = 0;
  bool showApproveButton = false;
  void getRequestedDocs() async {
    DatabaseReference _testRef =
        FirebaseDatabase.instance.ref('activerequests/' + widget.uid + '/docs');
    DatabaseEvent _event = await _testRef.once();
    
    if (mounted) {
      setState(() {
        verifiedDocCount = 0;
        requestedDocs = _event.snapshot.value as Map<String, dynamic>;
        
        requestedDocs.forEach((key, value) {
          if (value != null) {
            if (value['state'] == 2) verifiedDocCount++;
          }
        });
        if (verifiedDocCount == requestedDocs.length) showApproveButton = true;
        
      });
    }
  }

  void verifyDoc(index) async {
    DatabaseReference _testRef = FirebaseDatabase.instance.ref(
        'activerequests/' +
            widget.uid +
            '/docs/' +
            requestedDocs.keys.elementAt(index));
    _testRef.child("state").set(2);
  }

  void declineDoc(index) async {
    DatabaseReference _testRef = FirebaseDatabase.instance.ref(
        'activerequests/' +
            widget.uid +
            '/docs/' +
            requestedDocs.keys.elementAt(index));
    _testRef.set({
      "url": "",
      "state": 0,
    });
    _testRef = FirebaseDatabase.instance.ref('activerequests/' + widget.uid);
    _testRef.child('state').set(2);
  }

  void approveRequest() async {
    //set state of active request
    DatabaseReference _testRef =
        FirebaseDatabase.instance.ref('activerequests/' + widget.uid);
    _testRef.child("state").set(4);

    //move to previous Requests
    DatabaseReference _prevRequests =
        FirebaseDatabase.instance.ref('requests/' + widget.uid);
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
          .child(widget.uid)
          .child("0")
          .set(recentQuery.snapshot.value);
    }
    //_testRef.remove();
  }

  int getindex(index) {
    int cnt = 0;
    int ans = 0;
    dockeys.forEach((element) {
      if (element == index) ans = cnt;
      cnt++;
    });
    return ans;
  }

  Widget build(BuildContext context) {
    getRequestedDocs();
    return Scaffold(
        appBar: AppBar(
          title: Text('Verify Documents'),
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
                  ListTile(
                      autofocus: false,
                      contentPadding: EdgeInsets.fromLTRB(300, 25, 5, 5),
                      title: Row(
                        children: <Widget>[
                          Text(
                            docs[getindex(requestedDocs.keys.elementAt(index))],
                            style: TextStyle(fontSize: 25),
                          ),
                          Padding(
                            padding: EdgeInsets.fromLTRB(800, 5, 5, 5),
                            child: requestedDocs.values
                                        .elementAt(index)['state'] ==
                                    0
                                ? Text('awaiting upload.....',
                                    style: TextStyle(
                                        fontSize: 20, color: Colors.grey))
                                : (requestedDocs.values
                                            .elementAt(index)['state'] ==
                                        1
                                    ? (ElevatedButton(
                                        //style: ButtonStyle(backgroundColor: Colors.green),
                                        child: const Text('Verify'),
                                        style: ElevatedButton.styleFrom(
                                          minimumSize: Size(90, 60),
                                          primary: Colors.green,
                                        ),
                                        onPressed: () async {
                                          verifyDoc(index);
                                        }))
                                    : Text('Verified',
                                        style: TextStyle(
                                            fontSize: 20, color: Colors.green))
                                //Text('hi')
                                ),
                          ),
                          Padding(
                            padding: EdgeInsets.fromLTRB(5, 5, 5, 5),
                            child: requestedDocs.values
                                        .elementAt(index)['state'] ==
                                    0
                                ? Text('',
                                    style: TextStyle(
                                        fontSize: 20, color: Colors.grey))
                                : (requestedDocs.values
                                            .elementAt(index)['state'] ==
                                        1
                                    ? (ElevatedButton(
                                        //style: ButtonStyle(backgroundColor: Colors.green),
                                        child: const Text('Decline'),
                                        style: ElevatedButton.styleFrom(
                                          minimumSize: Size(90, 60),
                                          primary: Colors.red,
                                        ),
                                        onPressed: () async {
                                          declineDoc(index);
                                        }))
                                    : Icon(
                                        CupertinoIcons.check_mark_circled_solid,
                                        color: Colors.green,
                                      )
                                //Text('hi')
                                ),
                          ),
                        ],
                      )),
                  (showApproveButton == true &&
                          index == requestedDocs.length - 1)
                      ? Padding(
                          padding: EdgeInsets.all(10),
                          child: ElevatedButton(
                              child: const Text(
                                'Approve Request',
                                style: TextStyle(fontSize: 23),
                              ),
                              style: ElevatedButton.styleFrom(
                                minimumSize: Size(70, 60),
                                primary: Colors.purple,
                              ),
                              onPressed: () async {
                                approveRequest();
                                Navigator.pushReplacement(context,
                                    MaterialPageRoute(builder: (context) {
                                  return UploadStageScreen();
                                }));
                              }))
                      : Text(''),
                  Divider(
                    height: 3,
                  ),
                ],
              ));
            },
            itemCount: requestedDocs.length,
          ),
          isAlwaysShown: true,
        ));
  }
}
