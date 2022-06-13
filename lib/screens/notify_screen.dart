import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:bubble/bubble.dart';
import 'dart:math';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import '../api/translation_api.dart';

class ChatRoom extends StatefulWidget {
  @override
  final String uid;
  final String name;
  ChatRoom(this.uid, this.name);
  _ChatRoomState createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> {
  bool emptyString = true;
  TextEditingController _inputController = TextEditingController();
  Map<String, dynamic>  chatMsgs = {};
  final DateTime currentDate = DateTime.now();
  void _getChats() async {
    DatabaseReference _testRef =
        FirebaseDatabase.instance.ref('notifications/' + widget.uid);
    DatabaseEvent event = await _testRef.once();

    //print(currentDate.date);

    chatMsgs = event.snapshot.value as Map<String, dynamic>;
    //rprint(event.snapshot.value.toString());
    //print(mp.values.elementAt(0)['name']);
  }

  void _sendNotification(String msg) async {
    String date = DateFormat("dd MMMM yyyy").format(DateTime.now());
    String time = DateFormat("HH:mm:ss").format(DateTime.now());

    DatabaseReference _testRef =
        FirebaseDatabase.instance.ref('notifications/' + widget.uid);
    //DatabaseReference _newPostRef = _testRef.push();

    DatabaseReference _langRef =
        FirebaseDatabase.instance.ref('uidToPhone/' + widget.uid + '/language');
    DatabaseEvent _lang = await _langRef.once();

    String lang = _lang.snapshot.value as String;

    TranslationApi translator = TranslationApi();

    String translated_msg = await translator.translate(msg, 'en', lang);

    _testRef.push().set({
      'date': date,
      'msg': translated_msg,
      'time': time,
    });
  }

  
    

  Widget build(BuildContext context) {
    _getChats();
    
    return Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(
            color: Colors.black, //change your color here
          ),
          title: Text(
            widget.name + '\'s Notifications',
            style: TextStyle(color: Colors.black),
          ),
          backgroundColor: Colors.orange.shade400,
        ),
        backgroundColor: Colors.orange.shade100,
        body: Column(children: <Widget>[
          Expanded(
              child: RawScrollbar(
            thumbColor: Colors.grey,
            thickness: 15,
            child: CustomScrollView(
              slivers: <Widget>[
                SliverList(
                    delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    //print(chatMsgs[index]['date'].toString());
                    return MessageBubble(
                        chatMsgs.values.elementAt(index)['msg'].toString(),
                        chatMsgs.values.elementAt(index)['time'].toString(),
                        chatMsgs.values.elementAt(index)['date'].toString());
                  },
                  childCount: chatMsgs.length,
                )),
                /* SliverList(
                    delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    return MessageBubble(
                        chatMsgs[index]['date'].toString(),
                        true,
                       chatMsgs[index]['msg'].toString());
                  },
                  childCount: chatMsgs.length,
                )) */
              ],
            ),
          )),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.only(
                  left: 8.0,
                  top: 8.0,
                  bottom: 8.0,
                  right: 6.0,
                ),
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.96,
                  height: 20 * 2.5,
                  padding: EdgeInsets.only(
                    right: 10,
                    left: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(
                      Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: EdgeInsets.all(3.0),
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.7,
                          height: 20 * 2.5,
                          child: TextField(
                            maxLines: null,
                            onChanged: (String value) {
                              setState(() {
                                if (value != null || value != '')
                                  emptyString = false;
                                else if (value == '') emptyString = true;
                              });
                            },
                            keyboardType: TextInputType.multiline,
                            controller: _inputController,
                            cursorColor: Colors.black,
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.black,
                            ),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Type a message...',
                              hintStyle: TextStyle(
                                color: Colors.black,
                                fontSize: 19,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                  child: /* Padding(
                      padding: EdgeInsets.all(3.0),
                      child: RawMaterialButton(
                        elevation: 2.0,
                        fillColor: Colors.orange,
                        child: Icon(
                          CupertinoIcons.paperplane,
                          size: 15.0,
                        ),
                        padding: EdgeInsets.all(5.0),
                        shape: CircleBorder(),
                        onPressed: () {
                          if (_inputController.text.length > 0) {
                            _sendNotification(_inputController.text);
                            _inputController.text = '';
                          }
                        },
                      )) */
                      CircleAvatar(
                          backgroundColor: Colors.orange,
                          radius: 23,
                          child: RawMaterialButton(
                            elevation: 2.0,
                            fillColor: Colors.orange,
                            child: Icon(
                              CupertinoIcons.paperplane,
                              size: 15.0,
                            ),
                            padding: EdgeInsets.all(5.0),
                            shape: CircleBorder(),
                            onPressed: () {
                              if (_inputController.text.length > 0) {
                                _sendNotification(_inputController.text);
                                _inputController.text = '';
                              }
                            },
                          )))
            ],
          )
        ]));
  }
}

class MessageBubble extends StatelessWidget {
  final String msg;
  final String time;
  final String date;
  TextEditingController _controller = TextEditingController();
  MessageBubble(this.msg, this.time, this.date);

  @override
  Widget build(BuildContext context) {
    final val = (MediaQuery.of(context).size.width) / 1.6;
    return Padding(
      padding: msg.length < 50
          ? EdgeInsets.fromLTRB(val, 8, 8, 8)
          : (msg.length < 100
              ? EdgeInsets.fromLTRB(max(val - 200, 0), 8, 8, 8)
              : EdgeInsets.fromLTRB(max(val - 400, 0), 8, 8, 8)),
      child: Bubble(
        color: Colors.orange.shade300,
        shadowColor: Colors.black,
        elevation: 15.0,
        margin: BubbleEdges.only(top: 20, right: 18),
        nip: BubbleNip.rightTop,
        child: Padding(
            padding: EdgeInsets.all(8.0),
            child: Column(children: [
              Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    msg,
                    style: TextStyle(color: Colors.black, fontSize: 18),
                  )),
              Align(
                  alignment: Alignment.bottomRight,
                  child: Text(
                    date + ', ' + time,
                    style: TextStyle(color: Colors.black, fontSize: 15),
                  )),
            ])),
      ),
    );
  }
}
