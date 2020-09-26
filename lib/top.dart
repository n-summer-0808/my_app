import 'package:flutter/material.dart';

class Top extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('エリア選択'),
        ),
        body: ListView(children: [
          _menuItem("嵐山エリア", Icon(Icons.place), context, "/arashiyama"),
          _menuItem("祇園エリア", Icon(Icons.place), context, "/gion"),
          _menuItem("奈良エリア", Icon(Icons.place), context, "/nara"),
        ]),
      ),
    );
  }

  Widget _menuItem(
      String title, Icon icon, BuildContext context, String route) {
    return Container(
      decoration: new BoxDecoration(
          border:
              new Border(bottom: BorderSide(width: 1.0, color: Colors.grey))),
      child: ListTile(
        leading: icon,
        title: Text(
          title,
          style: TextStyle(color: Colors.black, fontSize: 18.0),
        ),
        onTap: () {
          Navigator.of(context).pushNamed(route);
        },
      ),
    );
  }
}
