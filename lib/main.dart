import 'package:flutter/material.dart';

import 'top.dart';
import 'show_congestion.dart';

Map<String, dynamic> jsonCongestion = {};

void main() {
  runApp(new MaterialApp(
    title: 'Navigation with Routes',
    routes: <String, WidgetBuilder>{
      '/': (_) => new Splash(),
      // '/': (_) => new Top(),  //エリア選択画面
      '/top': (_) => new Top(),
      '/arashiyama': (_) => new ShowPoICongestion('arashiyama'),
      '/gion': (_) => new ShowPoICongestion('gion'),
      '/nara': (_) => new ShowPoICongestion('nara'),
    },
  ));
}

class Splash extends StatefulWidget {
  @override
  _SplashState createState() => new _SplashState();
}

// 起動時のスプラッシュアニメーション（かっこいいの作りたいね）
class _SplashState extends State<Splash> {
  @override
  void initState() {
    super.initState();

    new Future.delayed(const Duration(seconds: 3))
        .then((value) => handleTimeout());
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: new Center(
        child: const CircularProgressIndicator(),
      ),
    );
  }

  void handleTimeout() {
    Navigator.of(context).pushReplacementNamed("/top");
  }
}
