import 'package:flutter/material.dart';
import 'package:SheelQuotient/model/question.dart';
import 'package:SheelQuotient/colors.dart';
import '../../colors.dart';

List<String> _optionChars = [];
String questionText = 'This is a Pikachar style question where you tap on character tiles?';
int rowTilesLimit = 6; // What is the max no. of tiles in a row
AnswerRows ansRows;
List<AnswerTile> aTiles = List<AnswerTile>();
List<OptionTile> opTiles = List<OptionTile>();
Map _answerChars = {
  "length": 6,
  "indexToInsert": 0
};

void setAnswerCharsFromData(Answer ans) {
  int lengthOfAnswer = ans.answer.length;
  print(lengthOfAnswer);
  _answerChars['length'] = lengthOfAnswer;
  for (int i = 0; i < lengthOfAnswer; i++) {
    _answerChars[i] = " ";
  }
}

class Pikachar extends StatefulWidget {
  String questText = questionText;
  List<String> optionChars;
  Answer answer;

  Pikachar(this.questText, this.optionChars) {
    Map<String, dynamic> jsonData = new Map<String, dynamic>();
    jsonData['_id'] = "5c66f999810d7b757e179d96";
    jsonData['answer'] = "મહાવીર ભગવાન";

    this.answer = new Answer.fromJson(jsonData);
  }

  @override
  _PikacharState createState() => new _PikacharState();
}

class _PikacharState extends State<Pikachar> {
  @override
  void initState() {
    super.initState();
    // todo: Set the optionChars to come from API
    if (widget.optionChars != null) {
      _optionChars = widget.optionChars;
    } else {
      _optionChars = [
        'સી', 'મં', 'ધ', 'ર', 'સ્વા', 'મી', 'દા', 'દા', 'ભ', 'ગ', 'વા',
        'ન', 'ની', 'રૂ', 'મા'
      ];
    }
    print(widget.answer);
    setAnswerCharsFromData(widget.answer);
  }

  @override
  Widget build(BuildContext context) {
    ansRows = new AnswerRows();
    return new ListView(
              children: <Widget>[
                question(),
                ansRows,
                optionTiles(),
              ],
    );
  }

  Widget question() {
    return new Container(
      padding: EdgeInsets.fromLTRB(20, 150, 20, 0),
      child: Text(
        widget.questText,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: kQuizBackgroundWhite,
        ),
        textScaleFactor: 2,
      ),
    );
  }

  Widget answerTiles() {
    return new Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 50),
      child: Row(
        children: <Widget>[
          answerTile(),
          answerTile(),
          answerTile(),
          answerTile(),
          answerTile(),
        ],
        mainAxisAlignment: MainAxisAlignment.spaceAround,
      ));
  }

  Widget answerTile() {
    return new Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      child: SizedBox(
        width: 40,
        height: 70,
      ),
      color: kQuizMain400,
    );
  }

  Widget optionTiles() {
    return new Column(
      children: createOptionRows(),
    );
  }

  List<Widget> createOptionRows() {
    List<Widget> cols = new List<Widget>();
    for (int i = 0; i < _optionChars.length; i = i + rowTilesLimit) {
      var optRow = optionRow(i);
      cols.add(optRow);
    }
    return cols;
  }

  Widget optionRow(int i) {
    return Container(
      padding: EdgeInsets.all(20),
      child: Row(
        children: createOptionTiles(i),
        mainAxisAlignment: MainAxisAlignment.spaceAround,
      ),
    );
  }

  List<StatefulWidget> createOptionTiles(int startingIndex) {
    List<OptionTile> tempOpTiles = List<OptionTile>();
    for (int i = startingIndex; i < _optionChars.length &&
      i < startingIndex + rowTilesLimit; i++) {
      var opTile = new OptionTile(i, _optionChars[i]);
      opTiles.add(opTile);
      tempOpTiles.add(opTile);
    }
    return tempOpTiles;
  }

  Widget optionTile(String text, int index) {
    return new GestureDetector(
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
          child: Text(
            text,
            textScaleFactor: 3,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        )
      )
    );
  }
}

class OptionTile extends StatefulWidget {
  int index;
  String char;
  _OptionTileState st;

  OptionTile(this.index, this.char);

  void rtrnCharFromAnswer() {
    st.rtrnCharFromAnswer();
  }

  _OptionTileState createState() {
    st = _OptionTileState(this.index, this.char);
    return st;
  }
}

class _OptionTileState extends State<OptionTile> {
  int index;
  String char;
  bool isActive = false;

  _OptionTileState(this.index, this.char);

  void rtrnCharFromAnswer() {
    setState(() {
      isActive = false;
    });
  }

  void tileTapped() {
    if (!isActive) {
      if (ansRows.addCharToAnswer(char, index)) {
        setState(() {
          isActive = true;
        });
      }
    }
  }

  Widget getWidget() {
    return new GestureDetector(
      onTap: tileTapped,
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
          child: Text(
            this.char,
            textScaleFactor: 3,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        color: isActive ? kQuizMain50 : kQuizBackgroundWhite,
      )
    );
  }

  Widget build(BuildContext context) {
    return new GestureDetector(
      onTap: tileTapped,
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
          child: Text(
            this.char,
            textScaleFactor: 3,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        color: isActive ? kQuizMain50 : kQuizBackgroundWhite,
      )
    );
  }
}

class AnswerRows extends StatefulWidget {
  //todo: @Milan: Please check, is calling methods of state from statefulwidget
  // the correct way, because setState can only be called from State.
  // Or is there another way? I had to hack it this way as I didn't know any
  // other way. This is not working with hot reload, the state becomes null.
  _AnswerRowsState st;

  _AnswerRowsState createState() {
    st = new _AnswerRowsState();
    return st;
  }

  /// Set the index to insert to the first blank answer tile
  /// Needs to be called after removing or adding an answer tile
  void findIndexToInsert() {
    int i = 0;
    for (; i < _answerChars["length"]; i++) {
      if (_answerChars[i] == "" || _answerChars[i] == " ") {
        break;
      }
    }
    // If all tiles full, then indexToInsert set to length + 1
    _answerChars["indexToInsert"] = i;
  }

  /// Adds the char to the answer tiles
  bool addCharToAnswer(String char, int opTileIndex) {
    return st.addChar(char, opTileIndex);
  }
}

class _AnswerRowsState extends State<AnswerRows> {

  bool addChar(String char, int opTileIndex) {
    int i = _answerChars["indexToInsert"];
    if (i >= _answerChars["length"]) {
      return false;
    } else {
      aTiles[i].setOpIndex(i, char, opTileIndex);
    }
    ansRows.findIndexToInsert();
    return true;
  }

  Widget build(BuildContext context) {
    return new Container(
      padding: EdgeInsets.symmetric(vertical: 20),
      child: new Column(
        children: createAnswerRows(),
      )
    );
  }

  List<Widget> createAnswerRows() {
    List<Widget> cols = new List<Widget>();
    for (int i = 0; i < _answerChars["length"]; i = i + rowTilesLimit) {
      var optRow = AnswerTiles(i);
      cols.add(optRow);
    }
    return cols;
  }
}

class AnswerTiles extends StatefulWidget {
  int startingIndex;

  AnswerTiles(this.startingIndex);

  _AnswerTilesState createState() => _AnswerTilesState(this.startingIndex);
}

class _AnswerTilesState extends State<AnswerTiles> {
  int startingIndex;

  _AnswerTilesState(this.startingIndex);

  Widget build(BuildContext context) {
    return new Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Row(
        children: createAnswerTiles(this.startingIndex),
        mainAxisAlignment: MainAxisAlignment.spaceAround,
      )
    );
  }

  createAnswerTiles(int startingIndex) {
    List<AnswerTile> tempAnswerTiles = new List<AnswerTile>();
    for (int i = startingIndex; i < _answerChars["length"] &&
      i < startingIndex + rowTilesLimit; i++) {
      var aTile = new AnswerTile(i);
      tempAnswerTiles.add(aTile);
      aTiles.add(aTile);
    }
    return tempAnswerTiles;
  }
}

class AnswerTile extends StatefulWidget {
  int index;
  _AnswerTileState st;

  AnswerTile(this.index);

  void setOpIndex(int i, String char, int opTileIndex) {
    st.setOpIndex(i, char, opTileIndex);
  }

  _AnswerTileState createState() {
    st = new _AnswerTileState(this.index);
    return st;
  }
}

class _AnswerTileState extends State<AnswerTile> {
  String char = "દા";
  int index;
  int indexOfOption;

  _AnswerTileState(this.index);

  void setOpIndex(int i, String char, int opTileIndex) {
    print(i.toString() + char + opTileIndex.toString());
    this.indexOfOption = opTileIndex;
    setState(() {
      print("Hi");
      _answerChars["indexToInsert"]++;
      _answerChars[i] = char;
    });
  }

  void answerTileTapped() {
    print("Reached here outside if" + indexOfOption.toString());
    if (this.indexOfOption != null) {
      print("Reached here");
      opTiles[indexOfOption].rtrnCharFromAnswer();
      indexOfOption = null;
      setState(() {
        _answerChars[index] = " ";
      });
      ansRows.findIndexToInsert();
    }
  }

  Widget build(BuildContext context) {
    return new GestureDetector(
      onTap: answerTileTapped,
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
          child: Text(
            _answerChars[index],
            textScaleFactor: 3,
            style: TextStyle(
              fontWeight: FontWeight.bold, color: kQuizSurfaceWhite),
          ),
        ),
        color: kQuizMain400,
      ),
    );
  }
}
