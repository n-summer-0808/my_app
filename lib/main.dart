import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import 'show_congestion.dart';

Map<String, dynamic> json_congestoin = {};

void main() {
  runApp(new MaterialApp(
    title: 'Navigation with Routes',
    routes: <String, WidgetBuilder>{
      '/': (_) => new Splash(),
      // '/': (_) => new Top(),  //エリア選択画面
      '/arashiyama': (_) => new Show_PoI_Congestion('arashiyama'),
      '/gion': (_) => new Show_PoI_Congestion('gion'),
      '/nara': (_) => new Show_PoI_Congestion('nara'),
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
    // TODO 選択画面の実装（現時点では嵐山に遷移）
    Navigator.of(context).pushReplacementNamed("/arashiyama");
  }
}
