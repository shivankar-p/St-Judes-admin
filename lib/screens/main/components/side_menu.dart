import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../loggedIn.dart';
import '../../login.dart';
import 'package:admin_app/main.dart';

class SideMenu extends StatelessWidget {
  const SideMenu({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          Container(
          height: 150,
          //color: Color.fromARGB(, 0, 0, b),
          child: DrawerHeader(
            child: Image.asset("assets/images/logo_black.png"),
          )),
          DrawerListTile(
            title: "Dashboard",
            icon: Icon(Icons.dashboard),
            press: () {},
          ),
          DrawerListTile(
            title: "Queries",
            icon: Icon(Icons.question_mark),
            press: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => MyApp(1)),
                (Route<dynamic> route) => false,
              );
            },
          ),
          DrawerListTile(
            title: "Logout",
            icon: Icon(Icons.logout),
            press: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => Login()),
                (Route<dynamic> route) => false,
              );
            },
          ),
        ],
      ),
    );
  }
}

class DrawerListTile extends StatelessWidget {
  const DrawerListTile({
    Key? key,
    // For selecting those three line once press "Command+D"
    required this.title,
    //required this.svgSrc,
    required this.icon,
    required this.press,
  }) : super(key: key);

  final String title;
  final Icon icon;
  final VoidCallback press;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: press,
      horizontalTitleGap: 0.0,
      leading: IconTheme(
          data: new IconThemeData(
              color: Colors.black), 
          child: icon,
      ),
      title: Text(
        title,
        style: TextStyle(color: Colors.black),
      ),
    );
  }
}
