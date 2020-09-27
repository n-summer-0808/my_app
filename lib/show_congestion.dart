import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:http/http.dart' as http;

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
              constraints: BoxConstraints.expand(height: 70),
              child: Container(
                color: Colors.lightBlue,
                // child: WeatherIcon(
                //   weather: json['area-info']['weather'],
                // ),
                child: Text(
                  "天気 : " + json['area-info']['weather'],
                ),
              ),
            ),
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
  _WeatherIconState createState() => _WeatherIconState();
}

class _WeatherIconState extends State<WeatherIcon> {
  final String weather;
  _WeatherIconState({this.weather});
  @override
  Widget build(BuildContext context) {
    Icon weatherIcon;
    switch (weather) {
      case 'sunny':
        weatherIcon = Icon(Icons.wb_sunny);
        break;
      case 'rain':
        weatherIcon = Icon(Icons.place);
        break;
      case 'cloudy':
        weatherIcon = Icon(Icons.wb_cloudy);
        break;
      default:
        weatherIcon = Icon(Icons.wb_cloudy);
        break;
    }
    if (weather.compareTo('sunny') == 0) {
      weatherIcon = Icon(Icons.wb_sunny);
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
      child: SimpleTimeSeriesChart.withSampleData(), // サンプルデータでグラフ描画
    );
  }
}

// グラフ描画用のデータ型を定義
class PoiSeriesTime {
  final DateTime time; // 時間
  final int poi; // point of interest

  PoiSeriesTime(this.time, this.poi);
}

class SimpleTimeSeriesChart extends StatelessWidget {
  final List<charts.Series> seriesList;
  final bool animate;

  SimpleTimeSeriesChart(this.seriesList, {this.animate});

  /// Creates a [TimeSeriesChart] with sample data and no transition.
  factory SimpleTimeSeriesChart.withSampleData() {
    return new SimpleTimeSeriesChart(
      _createSampleData(),
      // Disable animations for image tests.
      animate: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return new charts.TimeSeriesChart(
      seriesList,
      animate: animate,
      // Optionally pass in a [DateTimeFactory] used by the chart. The factory
      // should create the same type of [DateTime] as the data provided. If none
      // specified, the default creates local date time.
      dateTimeFactory: const charts.LocalDateTimeFactory(),
    );
  }

  /// Create one series with sample hard coded data.
  static List<charts.Series<TimeSeriesSales, DateTime>> _createSampleData() {
    final data = [
      new TimeSeriesSales(new DateTime(2017, 9, 19), 5),
      new TimeSeriesSales(new DateTime(2017, 9, 26), 25),
      new TimeSeriesSales(new DateTime(2017, 10, 3), 100),
      new TimeSeriesSales(new DateTime(2017, 10, 10), 75),
    ];

    return [
      new charts.Series<TimeSeriesSales, DateTime>(
        id: 'Sales',
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (TimeSeriesSales sales, _) => sales.time,
        measureFn: (TimeSeriesSales sales, _) => sales.sales,
        data: data,
      )
    ];
  }
}

class TimeSeriesSales {
  final DateTime time;
  final int sales;

  TimeSeriesSales(this.time, this.sales);
}
