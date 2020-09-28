import 'package:flutter/material.dart';
import 'dart:convert';
// import 'package:charts_flutter/flutter.dart' as charts;
import 'package:syncfusion_flutter_charts/charts.dart';
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
    print(url);

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
      child: CongestionDataChart(poiData),
      // child: CongestionDataChart.withPoIData(poiData),
    );
  }
}

class CongestionDataChart extends StatelessWidget {
  final Map<String, dynamic> poiData;
  CongestionDataChart(this.poiData);

  @override
  Widget build(BuildContext context) {
    final List<CongestionData> chartData = [];

    poiData["congestion"].forEach((key, value) {
      int hour = int.parse(key);
      Color color = Color.fromRGBO(169, 169, 169, 1);
      if (hour >= 10 && hour <= 18) {
        if (hour == 12) {
          color = Color.fromRGBO(255, 0, 102, 1);
        }
        chartData.add(new CongestionData(double.parse(key), value, color));
      }
    });

    return Scaffold(
        body: Center(
            child: Container(
                child: SfCartesianChart(
                    primaryXAxis:
                        NumericAxis(visibleMinimum: 9, visibleMaximum: 20),
                    primaryYAxis: NumericAxis(visibleMaximum: 100),
                    series: <ChartSeries>[
          ColumnSeries<CongestionData, dynamic>(
              dataSource: chartData,
              xValueMapper: (CongestionData points, _) => points.hour,
              yValueMapper: (CongestionData points, _) => points.points,
              pointColorMapper: (CongestionData points, Color) => points.color),
        ]))));
  }
}

class CongestionData {
  CongestionData(this.hour, this.points, this.color);
  final double hour; // packageの仕様上，double型以外認められない
  final int points;
  final Color color;
}
