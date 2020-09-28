import 'package:flutter/material.dart';

import 'top.dart';
import 'show_congestion.dart';
import 'package:syncfusion_flutter_core/core.dart';

Map<String, dynamic> jsonCongestion = {};

void main() {
  // package "syncfusion_flutter"のライセンス認証
  SyncfusionLicense.registerLicense(
      "NT8mJyc2IWhia31hfWN9Z2doYmN8YWt8YWNhY3NnaWFkaWNgcxIeaCcyKjJ9Njo0PH0nN2ATOiB9PTI6ICd9OSM=");
  runApp(new MaterialApp(
    title: 'Navigation with Routes',
    routes: <String, WidgetBuilder>{
      '/': (_) => new Splash(),
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
