import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:math';
import 'dart:convert';
import 'package:charts_flutter/flutter.dart' as charts;

void main() {
  // アプリ起動時にmainが呼び出される
  runApp(App()); // Appを呼ぶ
}

class App extends StatelessWidget {
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
    return Flexible(
      child: GridView.count(
        crossAxisCount: 2,
        children: List.generate(50, (index) {
          return Center(
            //child: MyHomePage(),
            child: Text(
              'Item $index',
              style: Theme.of(context).textTheme.headline5,
            ),
          );
        }),
      ),
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

// class _MyHomePageState extends State<MyHomePage> {
//   String _data = "Load JSON Data";

//   void _updateJsonData() {
//     setState(() {
//       loadJsonAsset();
//     });
//   }

//   Future<void> loadJsonAsset() async {
//     _data = "";
//     String loadData = await rootBundle.loadString('json/data.json');
//     final jsonResponse = json.decode(loadData);
//     jsonResponse.forEach((key, value) => _data = _data + '$key: $value \x0A');
//   }
// }

class ExportGraph extends StatefulWidget {
  @override
  _ExportGraphState createState() => _ExportGraphState();
}

class _ExportGraphState extends State<ExportGraph> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
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

  // EXCLUDE_FROM_GALLERY_DOCS_START
  // This section is excluded from being copied to the gallery.
  // It is used for creating random series data to demonstrate animation in
  // the example app only.
  factory SimpleTimeSeriesChart.withRandomData() {
    return new SimpleTimeSeriesChart(_createRandomData());
  }

  /// Create random data.
  static List<charts.Series<TimeSeriesSales, DateTime>> _createRandomData() {
    final random = new Random();

    final data = [
      new TimeSeriesSales(new DateTime(2017, 9, 19), random.nextInt(100)),
      new TimeSeriesSales(new DateTime(2017, 9, 26), random.nextInt(100)),
      new TimeSeriesSales(new DateTime(2017, 10, 3), random.nextInt(100)),
      new TimeSeriesSales(new DateTime(2017, 10, 10), random.nextInt(100)),
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
  // EXCLUDE_FROM_GALLERY_DOCS_END

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
