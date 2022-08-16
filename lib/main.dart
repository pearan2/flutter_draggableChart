import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyPage(),
    );
  }
}

class MyPage extends StatelessWidget {
  const MyPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DraggbleLineChart(
        dots: {100: 200, 150: 150, 200: 400},
      ),
    );
  }
}

class DraggbleLineChart extends StatefulWidget {
  final Map<double, double> dots;
  late final Map<double, String> titles;

  DraggbleLineChart({
    Key? key,
    required this.dots,
    Map<double, String>? titles,
  }) : super(key: key) {
    this.titles = titles ?? {for (final k in dots.keys) k: k.toString()};
  }

  @override
  State<DraggbleLineChart> createState() => _DraggbleLineChartState();
}

class _DraggbleLineChartState extends State<DraggbleLineChart> {
  late Map<double, double> _dots;
  late Map<double, String> _titles;

  double? _nowPanTargetX;

  @override
  void initState() {
    _dots = {...widget.dots};
    _titles = {...widget.titles};
    super.initState();
  }

  void _updateTargetDotY(double deltaY) {
    if (_nowPanTargetX == null) {
      return;
    } else {
      final newDots = {..._dots};
      newDots[_nowPanTargetX!] = _dots[_nowPanTargetX!]! + deltaY;
      setState(() => _dots = newDots);
    }
  }

  @override
  Widget build(BuildContext context) {
    final spots = _dots.keys.map((x) {
      final y = _dots[x]!;
      return FlSpot(x, y);
    }).toList();

    final lineBarData = [
      LineChartBarData(
          preventCurveOverShooting: true,
          spots: spots,
          isCurved: true,
          barWidth: 5,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: true,
          ),
          showingIndicators: [0]),
    ];
    return Column(
      children: [
        DataViewer(dots: widget.dots, titles: widget.titles, label: 'origin'),
        DataViewer(dots: _dots, titles: _titles, label: 'changed'),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(72.0),
            child: LineChart(
              LineChartData(
                gridData: FlGridData(),
                titlesData: FlTitlesData(
                  show: true,
                  topTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: ((value, meta) =>
                              _titles.containsKey(value)
                                  ? SideTitleWidget(
                                      axisSide: meta.axisSide,
                                      child: Text(_titles[value]!))
                                  : const SizedBox.shrink()))),
                ),
                lineTouchData: LineTouchData(
                    enabled: true,
                    touchCallback: (event, res) {
                      if (event is FlPanStartEvent) {
                        _nowPanTargetX = res?.lineBarSpots?[0].x;
                      } else if (event is FlPanEndEvent) {
                        _nowPanTargetX = null;
                      } else if (event is FlPanUpdateEvent) {
                        if (event.details.delta.dy < 0) {
                          _updateTargetDotY(1);
                        } else {
                          _updateTargetDotY(-1);
                        }
                      } else if (event is FlTapUpEvent) {
                        _nowPanTargetX = null;
                      }
                    }),
                lineBarsData: lineBarData,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class DataViewer extends StatelessWidget {
  final Map<double, double> dots;
  final Map<double, String> titles;
  final String label;

  const DataViewer({
    Key? key,
    required this.dots,
    required this.titles,
    required this.label,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [...titles.keys.map((e) => Text(e.toString()))],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [...dots.values.map((e) => Text(e.toString()))],
        )
      ],
    );
  }
}
