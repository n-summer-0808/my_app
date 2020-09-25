import 'package:flutter/material.dart';

void main() {
  runApp(App());
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final title = 'poi-view';
    return MaterialApp(
      theme: ThemeData(
          brightness: Brightness.light, primaryColor: Colors.blueGrey),
      home: Scaffold(
        appBar: AppBar(
          title: Text(title),
        ),
        body: Container(
          child: Column(
            children: <Widget>[
              Container(
                height: 100, // 縦幅
                child: ChangeForm(),
              ),
              PoiView(),
            ],
          ),
        ),
      ),
    );
  }
}

class PoiView extends StatefulWidget {
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
