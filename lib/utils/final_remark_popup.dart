import 'package:flutter/material.dart';
import '../screens/uploadstage_request_screen.dart';

class FinalRemark extends StatefulWidget {
  @override
  _FinalRemark createState() => _FinalRemark();
}

class _FinalRemark extends State<FinalRemark> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController RemarkController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  content: Stack(
                    children: <Widget>[
                      Positioned(
                        right: -40.0,
                        top: -40.0,
                        child: InkResponse(
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                          child: CircleAvatar(
                            child: Icon(Icons.close),
                            backgroundColor: Colors.red,
                          ),
                        ),
                      ),
                      Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.all(8.0),
                              child: TextFormField(
                                decoration: const InputDecoration(
                                  icon: const Icon(Icons.feedback),
                                  hintText: 'Enter Request closing remarks',
                                  labelText: 'Final Remarks',
                                ),
                                controller: RemarkController,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ElevatedButton(
                                child: Text("Submit"),
                                onPressed: () {
                                  Navigator.pop(context);
                                  Navigator.push(context,
                                    MaterialPageRoute(builder: (parentcontext) {
                                  return UploadStageScreen();
                                }));

                                },
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              });
        },
        child: Text("Open Popup"),
      ),
    );
  }
}
