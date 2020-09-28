import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:http/http.dart' as http;
import 'weather_icons_icons.dart';

class ShowPoICongestion extends StatelessWidget {
  final String areaName;
  ShowPoICongestion(this.areaName);

  @override
  Widget build(BuildContext context) {
    // タイトル表示用の設定(実装がダサい)
    String title;
    switch (areaName) {
      case 'arashiyama':
        title = '嵐山エリア';
        break;
      case 'gion':
        title = '祇園エリア';
        break;
      case 'nara':
        title = '奈良エリア';
        break;
      default:
        title = '';
        break;
    }

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text(title), // アプリ最上部のタイトル表示
        ),
        body: Container(
          child: PoiView(areaName), // グラフ表示を配置
        ),
      ),
    );
  }
}

class PoiView extends StatefulWidget {
  final String areaName;
  PoiView(this.areaName);

  @override
  _PoiViewState createState() => _PoiViewState(areaName);
}

class _PoiViewState extends State<PoiView> {
  final String areaName;
  _PoiViewState(this.areaName);

  @override
  Widget build(BuildContext context) {
    // TODO API側のルーティングを実装した後，url+=のコメントアウトを削除
    String url = 'https://m1-go.herokuapp.com/congestion/';
    String lat = '35';
    String lng = '135';
    url += 'areaname=' + areaName + '&lat=' + lat + '&lng=' + lng;

    // TODO ページ全体が読み込まれたタイミングでhttpリクエストを送信するように切り替える
    return FutureBuilder(
      future: getJson(url),
      builder: (context, snapshot) {
        // 非同期処理が完了している場合，天気と混雑度グラフを表示
        if (snapshot.hasData) {
          Map<String, dynamic> json = snapshot.data;
          return Column(children: <Widget>[
            ConstrainedBox(
                // 天候表示
                constraints: BoxConstraints.expand(height: 80),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'current weather : ',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                        fontSize: 20.0,
                      ),
                    ),
                    WeatherIcon(
                      weather: json['area-info']['weather'],
                    ),
                  ],
                )),
            Container(
              // グラフ表示
              child: Flexible(
                child: GridView.count(
                  crossAxisCount: 2,
                  children: List.generate(json['poi'].length, (index) {
                    return Center(
                      child: InsideGrid(poiData: json['poi'][index]),
                    );
                  }),
                ),
              ),
            ),
          ]);

          // 非同期処理が未完了の場合はインジケータを表示する
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}

// 自前のAPIサーバーからjsonファイルを取得
Future<Map<String, dynamic>> getJson(String url) async {
  var response = await http.get(url);
  final jsonResponse = json.decode(response.body);
  return jsonResponse;
}

/////////
//以下天気アイコン表示処理(作り中,未反映)
/////////
class WeatherIcon extends StatefulWidget {
  final String weather;
  WeatherIcon({this.weather});
  @override
  _WeatherIconState createState() => _WeatherIconState(weather: weather);
}

class _WeatherIconState extends State<WeatherIcon> {
  final String weather;
  _WeatherIconState({this.weather});
  @override
  Widget build(BuildContext context) {
    Icon weatherIcon;
    switch (weather) {
      case 'Clear':
        weatherIcon = Icon(
          WeatherIcons.sun,
          color: Colors.orange[700],
          size: 50.0,
        );
        break;
      case 'Rain':
      case 'Drizzle':
      case 'Thunderstorm':
        weatherIcon = Icon(
          WeatherIcons.rain,
          color: Colors.blue[700],
          size: 50.0,
        );
        break;
      default:
        weatherIcon = Icon(
          WeatherIcons.cloud,
          color: Colors.grey[800],
          size: 50.0,
        );
        break;
    }
    return weatherIcon;
  }
}

/////////
//以下グラフ描画処理
/////////

// グリッド内表示の生成
class InsideGrid extends StatefulWidget {
  final Map<String, dynamic> poiData; //上位Widgetから受け取りたいデータ
  InsideGrid({this.poiData}); //コンストラクタ
  @override
  _InsideGridState createState() => _InsideGridState(poiData: poiData);
}

class _InsideGridState extends State<InsideGrid> {
  final Map<String, dynamic> poiData;
  _InsideGridState({this.poiData});
  @override
  Widget build(BuildContext context) {
    return Column(children: <Widget>[
      Text(poiData['name']), // 場所名
      Flexible(
        flex: 3,
        child: PoiGraph(poiData: poiData), // グラフ
      ),
    ]);
  }
}

// グラフ描画
class PoiGraph extends StatefulWidget {
  final Map<String, dynamic> poiData;
  PoiGraph({this.poiData});
  @override
  _PoiGraphState createState() => _PoiGraphState(poiData: poiData);
}

class _PoiGraphState extends State<PoiGraph> {
  final Map<String, dynamic> poiData;
  _PoiGraphState({this.poiData});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CongestionDataChart.withPoIData(poiData),
    );
  }
}

/// 混雑度をSparkなグラフで描画
class CongestionDataChart extends StatelessWidget {
  final List<charts.Series> seriesList;
  final bool animate;

  CongestionDataChart(this.seriesList, {this.animate});

  factory CongestionDataChart.withPoIData(Map<String, dynamic> poiData) {
    return new CongestionDataChart(
      _createPoIData(poiData),
      animate: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return new charts.BarChart(
      seriesList,
      animate: animate,

      /// Assign a custom style for the measure axis.
      ///
      /// The NoneRenderSpec only draws an axis line (and even that can be hidden
      /// with showAxisLine=false).
      primaryMeasureAxis: new charts.NumericAxisSpec(
        renderSpec: new charts.NoneRenderSpec(),
        showAxisLine: true,
      ),

      /// This is an OrdinalAxisSpec to match up with BarChart's default
      /// ordinal domain axis (use NumericAxisSpec or DateTimeAxisSpec for
      /// other charts).
      domainAxis: new charts.OrdinalAxisSpec(
        // Make sure that we draw the domain axis line.
        showAxisLine: true,
        // viewport: charts.OrdinalViewport("10", 100)
        // renderSpec: new charts.NoneRenderSpec()
      ),

      // With a spark chart we likely don't want large chart margins.
      // 1px is the smallest we can make each margin.
      layoutConfig: new charts.LayoutConfig(
        leftMarginSpec: new charts.MarginSpec.fixedPixel(0),
        topMarginSpec: new charts.MarginSpec.fixedPixel(0),
        rightMarginSpec: new charts.MarginSpec.fixedPixel(0),
        // bottomMarginSpec: new charts.MarginSpec.fixedPixel(1)
      ),
    );
  }

  /// グラフ描画に使用するデータ生成
  static List<charts.Series<CongestionData, String>> _createPoIData(
      Map<String, dynamic> poiData) {
    List<CongestionData> data = [];

    poiData["congestion"].forEach((key, value) {
      int hour = int.parse(key);
      charts.Color barColor = charts.ColorUtil.fromDartColor(Colors.blue);
      if (hour >= 10 && hour <= 18) {
        print(value);
        if (hour == 14) {
          // TODO ユーザの現在時刻に合わせて強調（現在はデモ用に14時固定）
          barColor = charts.ColorUtil.fromDartColor(Colors.red);
        }
        data.add(new CongestionData(key, value, barColor));
      }
    });

    return [
      new charts.Series<CongestionData, String>(
        id: 'hour',
        domainFn: (CongestionData series, _) => series.hour,
        measureFn: (CongestionData series, _) => series.points,
        colorFn: (CongestionData series, _) => series.barColor,
        data: data,
      ),
    ];
  }
}

// 軸ありのグラフ
// class CongestionDataChart extends StatelessWidget {
//   final Map<String, dynamic> poiData;
//   CongestionDataChart(this.poiData);

//   // SimpleTimeSeriesChart(this.seriesList, {this.animate});

//   @override
//   Widget build(BuildContext context) {
//     List<CongestionData> data = [];

//     poiData["congestion"].forEach((key, value) {
//       // print(key);
//       int hour = int.parse(key);
//       if (hour >= 10 && hour <= 18) {
//         data.add(new CongestionData(
//             "1", value, charts.ColorUtil.fromDartColor(Colors.blue)));
//       }
//     });

//     List<charts.Series<CongestionData, String>> series = [
//       charts.Series(
//           id: "numbers",
//           data: data,
//           domainFn: (CongestionData series, _) => series.hour,
//           measureFn: (CongestionData series, _) => series.points,
//           colorFn: (CongestionData series, _) => series.barColor)
//     ];

//     return Container(
//       height: 400,
//       padding: EdgeInsets.all(20),
//       child: Card(
//         child: Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: Column(
//             children: <Widget>[
//               // Text(
//               //   "World of Warcraft numbers by day",
//               //   // style: Theme.of(context).textTheme.body2,
//               // ),
//               Expanded(
//                 child: charts.BarChart(series, animate: true),
//               )
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// 棒グラフ表示用の表示用のデータ構造
class CongestionData {
  final String hour; //時間
  final int points; //混雑度合い
  final charts.Color barColor; //グラフの色

  CongestionData(this.hour, this.points, this.barColor);
}
