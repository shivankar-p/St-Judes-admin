import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'loggedIn.dart';

TextEditingController nameController = TextEditingController();
TextEditingController passController = TextEditingController();

class SizeConfig {
  static late MediaQueryData _mediaQueryData;
  static late double screenWidth;
  static late double screenHeight;
  static late double blockSizeHorizontal;
  static late double blockSizeVertical;

  static late double _safeAreaHorizontal;
  static late double _safeAreaVertical;
  static late double safeBlockHorizontal;
  static late double safeBlockVertical;

  void init(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
    screenWidth = _mediaQueryData.size.width;
    screenHeight = _mediaQueryData.size.height;
    blockSizeHorizontal = screenWidth / 1000;
    blockSizeVertical = screenHeight / 1000;

    _safeAreaHorizontal =
        _mediaQueryData.padding.left + _mediaQueryData.padding.right;
    _safeAreaVertical =
        _mediaQueryData.padding.top + _mediaQueryData.padding.bottom;
    safeBlockHorizontal = (screenWidth - _safeAreaHorizontal) / 1000;
    safeBlockVertical = (screenHeight - _safeAreaVertical) / 1000;
  }
}

class Login extends StatefulWidget {
  Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _Login();
}

class _Login extends State<Login> {
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Stack(alignment: Alignment.center, children: <Widget>[
      Positioned(
        child: Container(
          constraints: BoxConstraints.expand(),
          decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage("images/final.png"),
                fit: BoxFit.cover),
          ),
        ),
      ),
      Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: <Widget>[
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
                width: 218 * SizeConfig.safeBlockHorizontal * 1.3,
                height: 288.45 * SizeConfig.safeBlockVertical * 1.3,
                decoration: BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage('images/Logo.png')))),
            SizedBox(height: 10 * SizeConfig.safeBlockVertical),
            Material(
              color: Colors.transparent,
              child: Text('St. Judes India Childcares',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color.fromARGB(255, 34, 95, 34),
                    //fontFamily: 'ProximaNovaRegular',
                    fontSize: 30 * SizeConfig.safeBlockHorizontal,
                    letterSpacing: 0,
                    fontWeight: FontWeight.normal,
                    height: 1,
                  )),
            )
          ],
        ),
        Container(
            height: 500 * SizeConfig.safeBlockVertical,
            width: 300 * SizeConfig.safeBlockHorizontal,
            decoration: BoxDecoration(
                borderRadius:
                    BorderRadius.circular(20 * SizeConfig.safeBlockVertical),
                color: Color.fromARGB(255, 255, 255, 255)),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Material(
                    color: Colors.transparent,
                    child: Text("Administrator",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color.fromARGB(255, 235, 140, 17),
                          fontFamily: 'ProximaNovaRegular',
                          fontSize: 30 * SizeConfig.safeBlockHorizontal,
                          letterSpacing: 0,
                          fontWeight: FontWeight.normal,
                          height: 1,
                        )),
                  ),
                  Material(
                    color: Colors.transparent,
                    child: Text("Sign in",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color.fromARGB(255, 3, 3, 3),
                          fontFamily: 'ProximaNovaRegular',
                          fontSize: 17 * SizeConfig.safeBlockHorizontal,
                          letterSpacing: 0,
                          fontWeight: FontWeight.normal,
                          height: 1,
                        )),
                  ),
                  SizedBox(height: 10),
                  Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: 20 * SizeConfig.safeBlockHorizontal,
                        vertical: 15 * SizeConfig.safeBlockVertical),
                    child: Material(
                      child: TextField(
                        keyboardType: TextInputType.number,
                        controller: nameController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Admin ID',
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: 20 * SizeConfig.safeBlockHorizontal,
                        vertical: 15 * SizeConfig.safeBlockVertical),
                    child: Material(
                      child: TextField(
                        keyboardType: TextInputType.number,
                        controller: passController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Password',
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height:10),
                  Container(
                      width: 150 * SizeConfig.blockSizeHorizontal,
                      height: 70 * SizeConfig.blockSizeVertical,
                      padding: EdgeInsets.symmetric(
                          vertical: 15 * SizeConfig.blockSizeVertical),
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            primary: Colors.black,
                          ),
                          //Submit
                          onPressed: () {
                            if(nameController.text == 'admin@gmail.com' && passController.text == 'admin')
                            {
                              Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => LoggedInScreen()),
                              (Route<dynamic> route) => false,
                              );
                              }
                          },
                          child: Text("Submit",
                              style: TextStyle(
                                  fontFamily: 'ProximaNovaRegular',
                                  fontSize: 20 * SizeConfig.blockSizeVertical,
                                  color: Color.fromARGB(255, 255, 255, 255)))))
                ]))
      ])
    ]);
  }
}
