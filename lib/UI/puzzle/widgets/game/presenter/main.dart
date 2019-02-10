import 'dart:convert';
import 'dart:math';

import 'package:encrypt/encrypt.dart';
import 'package:flutter/widgets.dart';
import 'package:kon_banega_mokshadhipati/UI/puzzle/data/board.dart';
import 'package:kon_banega_mokshadhipati/UI/puzzle/data/result.dart';
import 'package:kon_banega_mokshadhipati/UI/puzzle/domain/game.dart';
import 'package:kon_banega_mokshadhipati/UI/puzzle/utils/serializable.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GamePresenterWidget extends StatefulWidget {
  static const SUPPORTED_SIZES = [3, 4, 5];

  final Widget child;

  final Function(Result) onSolve;

  GamePresenterWidget({@required this.child, this.onSolve});

  static GamePresenterWidgetState of(BuildContext context) {
    return (context.inheritFromWidgetOfExactType(_InheritedStateContainer)
            as _InheritedStateContainer)
        .data;
  }

  @override
  GamePresenterWidgetState createState() => GamePresenterWidgetState();
}

class GamePresenterWidgetState extends State<GamePresenterWidget>
    with WidgetsBindingObserver {
  static const TIME_STOPPED = 0;

  static const _SALSA_KEY = 'Ro9ndPUceXQQL8GS';
  static const _SALSA_IV = '84bgee3v';

  static const _KEY_STATE = 'state';

  /// Encrypter to protected saved states of the game and
  /// make hacking a lil bit harder.
  final _encrypter = Encrypter(Salsa20(_SALSA_KEY, _SALSA_IV));

  final Game game = Game.instance;

  Board board;

  int steps;

  int time;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    board = null;
    steps = null;
    time = TIME_STOPPED;

    _loadState();
  }

  void _loadState() async {
    final prefs = await SharedPreferences.getInstance();
    final encryptedText = prefs.getString(_KEY_STATE) ?? '';
    final plainText = _encrypter.decrypt(encryptedText);

    dynamic jsonMap;
    try {
      jsonMap = json.decode(plainText);
    } catch (FormatException) {
      jsonMap = Map<String, dynamic>();
    }

    int elapsedTime;
    int time;
    int steps;
    Board board;

    try {
      final deserializer = MapSerializeInput(map: jsonMap);
      const boardFactory = BoardDeserializableFactory();
      elapsedTime = deserializer.readInt();
      time = deserializer.readInt();
      steps = deserializer.readInt();
      board = deserializer.readDeserializable(boardFactory);
    } catch (Exception) {}

    final now = DateTime.now().millisecondsSinceEpoch;
    if ( // validate time
        time == null ||
            time < 0 ||
            time > now ||
            time > 0 && elapsedTime > now - time ||
            // validate steps
            steps == null ||
            steps < 0 ||
            // validate board
            board == null) {
      time = TIME_STOPPED;
      steps = 0;
      // Initialize empty board with a classic
      // pattern.
      const size = 3;
      board = _createBoard(size);
    }

    setState(() {
      this.time = time;
      this.steps = steps;
      this.board = board;
    });
  }

  Board _createBoard(int size) =>
      Board.create(size, (n) => Point(n % size, n ~/ size));

  void playStop() {
    if (isPlaying()) {
      stop();
    } else {
      play();
    }
  }

  void play() {
    assert(board != null);

    final now = DateTime.now().millisecondsSinceEpoch;
    setState(() {
      time = now;
      steps = 0;
      board =
          game.shuffle(game.hardest(board), amount: board.size * board.size);
    });
  }

  void stop() {
    setState(() {
      time = TIME_STOPPED;
      steps = 0;
    });
  }

  bool isPlaying() => time != TIME_STOPPED;

  void resize(int size) {
    setState(() {
      time = TIME_STOPPED;
      steps = 0;
      board = _createBoard(size);
    });
  }

  void tap({@required Point<int> point}) {
    assert(board != null);
    assert(point != null);

    setState(() {
      board = game.tap(board, point: point);

      if (isPlaying()) {
        // Increment the amount of steps.
        steps = steps + 1;

        // Stop if a user has solved the
        // board.
        if (board.isSolved()) {
          final now = DateTime.now().millisecondsSinceEpoch;
          final result = Result(
            steps: steps,
            time: now - time,
            size: board.size,
          );

          widget.onSolve?.call(result);

          stop();
        }
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.suspending:
        _saveState();
        break;
      default:
        break;
    }
  }

  void _saveState() async {
    final prefs = await SharedPreferences.getInstance();
    final serializer = MapSerializeOutput();

    if (board == null) {
      // Clear the current state, loading this will recreate
      // the board.
      prefs.setString(_KEY_STATE, null);
      return;
    }

    // Write the delta of time, so user can not close the app, change
    // time and go back so easily.
    final now = DateTime.now().millisecondsSinceEpoch;
    final elapsedTime = now - time;

    serializer.writeInt(elapsedTime);
    serializer.writeInt(time);
    serializer.writeInt(steps);
    serializer.writeSerializable(board);

    final plainText = serializer.toJsonString();
    final encryptedText = _encrypter.encrypt(plainText);
    prefs.setString(_KEY_STATE, encryptedText);
  }

  @override
  Widget build(BuildContext context) {
    return new _InheritedStateContainer(
      data: this,
      child: widget.child,
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}

class _InheritedStateContainer extends InheritedWidget {
  final GamePresenterWidgetState data;

  _InheritedStateContainer({
    Key key,
    @required this.data,
    @required Widget child,
  }) : super(key: key, child: child);

  @override
  bool updateShouldNotify(_InheritedStateContainer old) => true;
}