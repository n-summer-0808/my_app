import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:math';
import 'dart:convert';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:json_annotation/json_annotation.dart';
import 'package:http/http.dart' as http;

void main() {
  // アプリ起動時にmainが呼び出される
  runApp(MyApp()); // Appを呼ぶ
}

// 自前のAPIサーバーからjsonファイルを取得
Future<Map<String, dynamic>> get_json(String url) async {
  var response = await http.get(url);
  String _data = '';
  final jsonResponse = json.decode(response.body);
  return jsonResponse;
}

class MyApp extends StatelessWidget {
  // mainから呼ばれる
  @override
  Widget build(BuildContext context) {
    final title = 'poi-view';
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text(title), // アプリ最上部のタイトル表示
        ),
        body: Container(
          child: Column(
            // 複数のwidgetを縦に配置
            children: <Widget>[
              Container(
                height: 100, // 高さを指定
                child: ChangeForm(), // エリア指定フォームを配置
              ),
              PoiView(), // グラフ表示を配置
            ],
          ),
        ),
      ),
    );
  }
}

class PoiView extends StatefulWidget {
  // グラフ表示
  @override
  _PoiViewState createState() => _PoiViewState();
}

class _PoiViewState extends State<PoiView> {
  @override
  Widget build(BuildContext context) {
    String url = 'https://m1-go.herokuapp.com/congestion';

    // 非同期処理用のBuiderを呼び出し
    return FutureBuilder(
      future: get_json(url),
      builder: (context, snapshot) {
        // 非同期処理が完了している場合，Flexibleなviewを表示
        if (snapshot.hasData) {
          Map<String, dynamic> json = snapshot.data;
          // print(json);
          return Flexible(
            child: GridView.count(
              crossAxisCount: 2,
              children: List.generate(json['poi'].length, (index) {
                return Center(
                  child: InsideGrid(poiData: json['poi'][index]),
                );
              }),
            ),
          );

          // 非同期処理が未完了の場合はインジケータを表示する
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}

class ChangeForm extends StatefulWidget {
  @override
  _ChangeFormState createState() => _ChangeFormState();
}

class _ChangeFormState extends State<ChangeForm> {
  // エリア指定フォーム
  String _defaultValue = '嵐山エリア';
  List<String> _list = <String>['嵐山エリア', '祇園エリア', '奈良エリア'];
  String _text = '';

  void _handleChange(String newValue) {
    setState(() {
      _text = newValue;
      _defaultValue = newValue;
    });
  }

  Widget build(BuildContext context) {
    return Center(
      child: DropdownButton<String>(
        value: _defaultValue,
        onChanged: _handleChange,
        items: _list.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
      ),
    );
  }
}

// グリッド内表示の生成
class InsideGrid extends StatefulWidget {
  final Map<String, dynamic> poiData; //上位Widgetから受け取りたいデータ
  InsideGrid({this.poiData}); //コンストラクタ
  @override
  _InsideGridState createState() => _InsideGridState(poiData: poiData);
}

class _InsideGridState extends State<InsideGrid> {
  final Map<String, dynamic> poiData; //上位Widgetから受け取りたいデータ
  _InsideGridState({this.poiData}); //コンストラクタ
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

/// Sample time series data type.
class TimeSeriesSales {
  final DateTime time;
  final int sales;

  TimeSeriesSales(this.time, this.sales);
}
