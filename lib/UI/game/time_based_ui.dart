import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_circular_chart/flutter_circular_chart.dart';

import '../../colors.dart';
import '../../common.dart';

class TimeBasedUI extends StatefulWidget {
  @override
  State createState() => new TimeBasedUIState();
}

class TimeBasedUIState extends State<TimeBasedUI> {
  Timer _timer;
  int _timeInSeconds = 30; // question timer
  double _remaining = 100; // do not edit
  double _step = 0; // do not edit

  void startTimer() {
    _step = 100 / _timeInSeconds;
    const oneSec = const Duration(seconds: 1);
    _timer = new Timer.periodic(
      oneSec,
      (Timer timer) => setState(
            () {
              if (_timeInSeconds < 1) {
                timer.cancel();
              } else {
                _remaining = _remaining - _step;
                _chartKey.currentState.updateData(
                  <CircularStackEntry>[
                    new CircularStackEntry(
                      <CircularSegmentEntry>[
                        new CircularSegmentEntry(
                            _timeInSeconds == 1 ? 0 : _remaining, kQuizMain400,
                            rankKey: 'completed'),
                        new CircularSegmentEntry(
                            100, kQuizMain400.withAlpha(50),
                            rankKey: 'remaining'),
                      ],
                      rankKey: 'progress',
                    ),
                  ],
                );
                _timeInSeconds = _timeInSeconds - 1;
              }
            },
          ),
    );
  }

  @override
  initState() {
    super.initState();
    startTimer();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  final GlobalKey<AnimatedCircularChartState> _chartKey =
      new GlobalKey<AnimatedCircularChartState>();

  @override
  Widget build(BuildContext context) {
    Widget _timeIndicator() {
      return new AnimatedCircularChart(
        key: _chartKey,
        size: const Size(100.0, 100.0),
        edgeStyle: SegmentEdgeStyle.round,
        holeRadius: 25,
        initialChartData: <CircularStackEntry>[
          new CircularStackEntry(
            <CircularSegmentEntry>[
              new CircularSegmentEntry(
                0,
                kQuizMain400,
                rankKey: 'completed',
              ),
              new CircularSegmentEntry(
                100,
                kQuizMain400.withAlpha(50),
                rankKey: 'remaining',
              ),
            ],
            rankKey: 'progress',
          ),
        ],
        chartType: CircularChartType.Radial,
        percentageValues: true,
        holeLabel: "$_timeInSeconds",
        labelStyle: new TextStyle(
          color: Colors.blueGrey[600],
          fontWeight: FontWeight.bold,
          fontSize: 30.0,
        ),
      );
    }

    Widget _appBar() {
      return new Container(
        padding: EdgeInsets.fromLTRB(15, 15, 15, 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                print('back button');
              },
            ),
            Text('Time based UI',textScaleFactor: 1.5,),
            CommonFunction.pointsUI(context: context, point: '120'),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: kBackgroundGrediant1,
      body: SafeArea(
        child: ListView(
          children: <Widget>[
            _appBar(),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                _timeIndicator(),
              ],
            )
          ],
        ),
      ),
    );
  }
}
