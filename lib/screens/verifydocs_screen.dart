import 'package:admin_app/screens/loggedIn.dart';
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
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../utils/final_remark_popup.dart';
import 'dart:html' as html;
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast_web.dart';
import 'package:file_saver/file_saver_web.dart';
import 'package:archive/archive.dart';
import 'dart:typed_data';
import 'package:uri_to_file/uri_to_file.dart';
import '../utils/upload_docs_picker.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../api/translation_api.dart';

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

class _verifyScreen extends State<verifyScreen> {
  Map<String, dynamic> requestedDocs = {};
  int verifiedDocCount = 0;
  bool showApproveButton = false;
  int len = 0;
  void getRequestedDocs() async {
    DatabaseReference _testRef =
        FirebaseDatabase.instance.ref('activerequests/' + widget.uid + '/docs');
    DatabaseEvent _event = await _testRef.once();

    if (mounted) {
      setState(() {
        verifiedDocCount = 0;
        if (_event.snapshot.value != null) {
          requestedDocs = _event.snapshot.value as Map<String, dynamic>;
          len = requestedDocs.length;
        } else
          requestedDocs = {};

        requestedDocs.forEach((key, value) {
          if (value != null) {
            if (value['state'] == 2) verifiedDocCount++;
          }
        });
        if (verifiedDocCount == requestedDocs.length) showApproveButton = true;
      });
    }
  }

  dynamic getFile(String url) async {
    File file = await toFile(url);
    return file;
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

  void download_helper() async {
    List<String> filename = [];
    List<String> files = [];

    DatabaseReference _testRef =
        FirebaseDatabase.instance.ref('activerequests/' + widget.uid + '/docs');
    DatabaseEvent _event = await _testRef.once();

    Map<String, dynamic> mp = _event.snapshot.value as Map<String, dynamic>;

    _testRef = FirebaseDatabase.instance.ref('requests/' + widget.uid);
    _event = await _testRef.once();
    String reqno = '0';
    if (_event.snapshot.value != null) {
      List<dynamic> lst = _event.snapshot.value as List<dynamic>;
      reqno = lst.length.toString();
    }

    mp.forEach(
      (key, value) {
        int cnt = 0;
        value['url'].forEach(
          (keychild, valuechild) {
            filename.add(key + '_' + cnt.toString() + getExtension(valuechild));
            files.add(valuechild);
            cnt++;
          },
        );
      },
    );

    downloadZip(context, filename, files, reqno);
  }

  static var httpClient = http.Client();

  dynamic downloadZip(context, List<String> filenames, files, reqno) async {
    var encoder = ZipEncoder();
    var archive = Archive();
    print('files ');

    for (var i = 0; i < files.length; i++) {
      http.Response response = await http.get(
        Uri.parse(files[i]),
      );

      ArchiveFile archiveFiles = ArchiveFile.stream(
          filenames[i].toString(),
          response.bodyBytes.elementSizeInBytes,
          InputStream(response.bodyBytes));

      archive.addFile(archiveFiles);
    }
    var outputStream = OutputStream(
      byteOrder: LITTLE_ENDIAN,
    );
    var bytes = encoder.encode(archive,
        level: Deflate.BEST_COMPRESSION, output: outputStream);
    //print(bytes);
    downloadFile(widget.uid + "_" + reqno + ".zip", bytes);
  }

  downloadFile(String fileName, List<int>? inp) {
    Uint8List bytes = Uint8List.fromList(inp!);
    final blob = html.Blob([bytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.document.createElement('a') as html.AnchorElement
      ..href = url
      ..style.display = 'none'
      ..download = fileName;
    html.document.body!.children.add(anchor);

// download
    anchor.click();

// cleanup
    html.document.body!.children.remove(anchor);
    html.Url.revokeObjectUrl(url);
  }

  void approveRequest(String finalRemarks) async {
    //set state of active request
    DatabaseReference _testRef =
        FirebaseDatabase.instance.ref('activerequests/' + widget.uid);
    _testRef.child("state").set(4);
    _testRef.child("close_remarks").set(finalRemarks);

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

  void removeRequestedDoc(index) {
    DatabaseReference _testRef = FirebaseDatabase.instance.ref(
        'activerequests/' +
            widget.uid +
            '/docs/' +
            requestedDocs.keys.elementAt(index));
    _testRef.remove();
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

    List<dynamic> chatMsgs = [];
    if (_event.snapshot.value != null)
      chatMsgs = _event.snapshot.value as List<dynamic>;
    _testRef.child(chatMsgs.length.toString()).set({
      'date': date,
      'msg': translated_msg,
      'time': time,
    });
  }

  String getExtension(url) {
    url = url.toString();
    url = url.split('?')[0];
    url = url.split('/').last;
    return url.contains('.') ? url.substring(url.lastIndexOf('.')) : "";
  }

  List<int> cur = List.filled(100, 0);
  List<dynamic> cont = List.filled(100, CarouselController());
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
              bool flag = true;
              Map<String, dynamic> urlmap = {};

              if (requestedDocs.values.elementAt(index)['url'] == '')
                flag = false;
              else {
                urlmap = requestedDocs.values.elementAt(index)['url'];
              }
              List<String> imgs = [];
              int doclen = 0;
              if (flag) {
                urlmap.forEach((key, value) {
                  imgs.add(value);
                });
                doclen = imgs.length;
              }

              void animateToSlide(int index) =>
                  cont[index].animateToPage(index);

              Widget buildIndicator() => AnimatedSmoothIndicator(
                    activeIndex: cur[index],
                    onDotClicked: animateToSlide,
                    count: imgs.length,
                    effect: SlideEffect(
                        activeDotColor: Colors.orange,
                        dotWidth: 15,
                        dotHeight: 15),
                  );

              void previous() {
                cont[index].previousPage(duration: Duration(milliseconds: 500));
              }

              void next() {
                cont[index].nextPage(duration: Duration(milliseconds: 500));
              }

              Widget buildButtons({bool stretch = false}) =>
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.all(10),
                          primary: Colors.orange,
                        ),
                        onPressed: previous,
                        child: Icon(Icons.arrow_back)),
                    SizedBox(
                      width: 20,
                    ),
                    Text((cur[index]+1).toString() + '/' + imgs.length.toString(),
                    style: TextStyle(fontSize: 20),),
                    SizedBox(
                      width: 20,
                    ),
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.all(10),
                          primary: Colors.orange,
                        ),
                        onPressed: next,
                        child: Icon(Icons.arrow_forward)),
                  ]);

              return Material(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ExpansionTile(
                      /* autofocus: false,
                      contentPadding: EdgeInsets.fromLTRB(300, 25, 5, 5), */
                      children: [
                        /* if (requestedDocs.values.elementAt(index)['url'] == '')
                          Text('')
                        else
                          Image.network(
                              requestedDocs.values.elementAt(index)['url']) */
                        flag == false
                            ? Text('')
                            : (Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                    SizedBox(
                                      height: 10,
                                    ),
                                    buildButtons(),
                                    const SizedBox(
                                      height: 32,
                                    ),
                                    buildIndicator(),
                                    const SizedBox(
                                      height: 32,
                                    ),
                                    CarouselSlider(
                                      carouselController: cont[index],
                                      options: CarouselOptions(
                                          height: 400,
                                          enableInfiniteScroll: false,
                                          autoPlayAnimationDuration:
                                              Duration(seconds: 2),
                                          viewportFraction: 1,
                                          onPageChanged: (car_index, reason) =>
                                              {
                                                setState(() =>
                                                    cur[index] = car_index)
                                              }),
                                      items: imgs.map((i) {
                                        return Builder(
                                          builder: (BuildContext context) {
                                            return Container(
                                                width: (getExtension(i) !=
                                                        '.pdf'
                                                    ? (MediaQuery.of(context)
                                                        .size
                                                        .width)
                                                    : 120),
                                                margin: EdgeInsets.symmetric(
                                                    horizontal: 5.0),
                                                child: getExtension(i) != '.pdf'
                                                    ? Image.network(i)
                                                    : (Container(
                                                        alignment:
                                                            Alignment.topCenter,
                                                        width: 50,
                                                        child: ElevatedButton(
                                                          child: Row(children: [
                                                            Text('open PDF'),
                                                            Icon(Icons
                                                                .picture_as_pdf)
                                                          ]),
                                                          style: ElevatedButton
                                                              .styleFrom(
                                                                  primary: Colors
                                                                      .orange,
                                                                  minimumSize:
                                                                      Size(70,
                                                                          60)),
                                                          onPressed: () {
                                                            html.window.open(
                                                                i, "_blank");
                                                          },
                                                        ))));
                                          },
                                        );
                                      }).toList(),
                                    ),
                                  ]))
                      ],
                      title: Row(
                        children: <Widget>[
                          Container(
                              width: 1365,
                              padding: EdgeInsets.fromLTRB(200, 5, 5, 5),
                              child: Padding(
                                  padding: EdgeInsets.all(20),
                                  child: Text(
                                    docs[getindex(
                                        requestedDocs.keys.elementAt(index))],
                                    style: TextStyle(fontSize: 25),
                                  ))),
                          Container(
                              width: 200,
                              child: Row(children: <Widget>[
                                Padding(
                                  padding: EdgeInsets.fromLTRB(5, 5, 5, 5),
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
                                                notify_user(
                                                    widget.uid,
                                                    "Document Verified: Your document " +
                                                        docs[getindex(
                                                            requestedDocs.keys
                                                                .elementAt(
                                                                    index))] +
                                                        "has been verified!");
                                                verifyDoc(index);
                                              }))
                                          : Text('Verified',
                                              style: TextStyle(
                                                  fontSize: 20,
                                                  color: Colors.green))
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
                                                notify_user(
                                                    widget.uid,
                                                    "Document Rejected: Your document " +
                                                        docs[getindex(
                                                            requestedDocs.keys
                                                                .elementAt(
                                                                    index))] +
                                                        "has been Rejected. Please reupload the document");
                                                declineDoc(index);
                                              }))
                                          : Icon(
                                              CupertinoIcons
                                                  .check_mark_circled_solid,
                                              color: Colors.green,
                                            )
                                      //Text('hi')
                                      ),
                                )
                              ])),
                          Padding(
                              padding: EdgeInsets.fromLTRB(200, 5, 5, 5),
                              child: IconButton(
                                icon: const Icon(Icons.delete_forever),
                                color: Colors.red,
                                onPressed: () {
                                  removeRequestedDoc(index);
                                },
                              ))
                        ],
                      )),
                  (index == requestedDocs.length - 1)
                      ? (Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                              showApproveButton == true
                                  ? (Padding(
                                      padding: EdgeInsets.all(10),
                                      child: ElevatedButton(
                                          child: const Text(
                                            'Approve Request',
                                            style: TextStyle(fontSize: 23),
                                          ),
                                          style: ElevatedButton.styleFrom(
                                            minimumSize: Size(70, 60),
                                            primary: Colors.green,
                                          ),
                                          onPressed: () async {
                                            TextEditingController
                                                RemarkController =
                                                TextEditingController();
                                            return showDialog(
                                                context: context,
                                                builder:
                                                    (BuildContext context) {
                                                  return AlertDialog(
                                                    content: Stack(
                                                      children: <Widget>[
                                                        Positioned(
                                                          right: -40.0,
                                                          top: -40.0,
                                                          child: InkResponse(
                                                            onTap: () {
                                                              Navigator.of(
                                                                      context)
                                                                  .pop();
                                                            },
                                                            child: CircleAvatar(
                                                              child: Icon(
                                                                  Icons.close),
                                                              backgroundColor:
                                                                  Colors.red,
                                                            ),
                                                          ),
                                                        ),
                                                        Form(
                                                          child: Column(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            children: <Widget>[
                                                              Padding(
                                                                padding:
                                                                    EdgeInsets
                                                                        .all(
                                                                            8.0),
                                                                child:
                                                                    TextFormField(
                                                                  decoration:
                                                                      const InputDecoration(
                                                                    icon: const Icon(
                                                                        Icons
                                                                            .feedback),
                                                                    hintText:
                                                                        'Enter Request closing remarks',
                                                                    labelText:
                                                                        'Final Remarks',
                                                                  ),
                                                                  controller:
                                                                      RemarkController,
                                                                ),
                                                              ),
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .all(
                                                                        8.0),
                                                                child:
                                                                    ElevatedButton(
                                                                        style: ElevatedButton
                                                                            .styleFrom(
                                                                          primary:
                                                                              Colors.orange,
                                                                        ),
                                                                        child: Text(
                                                                            "Submit"),
                                                                        onPressed:
                                                                            () {
                                                                          approveRequest(
                                                                              RemarkController.text);
                                                                          notify_user(
                                                                              widget.uid,
                                                                              "Request Approved: Your Requested has been approved.\n Admin Remarks: " + RemarkController.text);

                                                                          Navigator.pop(
                                                                              context);
                                                                          Navigator.pushReplacement(
                                                                              context,
                                                                              MaterialPageRoute(builder: (context) {
                                                                            return LoggedInScreen();
                                                                          }));
                                                                        }),
                                                              )
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                });
                                          })))
                                  : Text(''),
                              showApproveButton == true
                                  ? (Padding(
                                      padding: EdgeInsets.all(10),
                                      child: ElevatedButton(
                                          child: Row(children: [
                                            const Text(
                                              'Download zip',
                                              style: TextStyle(fontSize: 23),
                                            ),
                                            Padding(
                                                padding: EdgeInsets.fromLTRB(
                                                    10, 5, 5, 5),
                                                child: Icon(
                                                    Icons.folder_zip_outlined))
                                          ]),
                                          style: ElevatedButton.styleFrom(
                                            minimumSize: Size(70, 60),
                                            primary: Colors.brown.shade400,
                                          ),
                                          onPressed: () async {
                                            download_helper();
                                          })))
                                  : Text(''),
                              Padding(
                                  padding: EdgeInsets.all(10),
                                  child: ElevatedButton(
                                      child: const Text(
                                        'Request more Docs',
                                        style: TextStyle(fontSize: 23),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        minimumSize: Size(70, 60),
                                        primary: Colors.orange.shade300,
                                      ),
                                      onPressed: () async {
                                        Navigator.push(context,
                                            MaterialPageRoute(
                                                builder: (context) {
                                          return docPicker(widget.uid, 1);
                                        }));
                                      })),
                            ]))
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
