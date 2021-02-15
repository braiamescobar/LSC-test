import 'dart:io';
import 'dart:convert';
import 'dart:async' show Future;
import 'package:flutter/services.dart' show rootBundle;

import 'package:flutter/material.dart';
import 'package:flutter_gifimage/flutter_gifimage.dart';
import 'package:flutter_spinbox/material.dart';
import 'package:csv/csv.dart';

import '../models/question_info.dart';

class PreguntasScreen extends StatefulWidget {
  @override
  _PreguntasScreenState createState() => _PreguntasScreenState();
}

class _PreguntasScreenState extends State<PreguntasScreen>
    with TickerProviderStateMixin {
  GifController controller1;
  Color colorQuestion = Colors.white;
  Color colorImage = Colors.white;
  Color cancelColor = Colors.grey;
  Color checkColor = Colors.grey;
  String dropdownValue = 'Días';
  String dropdownValue2 = 'al día';

  var innerQactive = 0;
  String action = '';
  String subQuestionActiveAux = 'No';

  var currentQInfo = QuestionInfo();

  String answerSel = 'none';
  List<List<String>> questionMx;
  List answerMx;
  // Init answerMx
  List initAnswerMx() {
    var answerMx = new List(5);
    for (var i = 0; i < 5; i++) {
      answerMx[i] = List(6);
    }
    return answerMx;
  }

  Future<List<List<String>>> loadAsset() async {
    //auxText = await rootBundle.loadString('assets/antecedentes2.txt');
    List<List<String>> questions = [];
    await rootBundle
        .loadString('assets/files/antecedentes_habitos2.txt')
        .then((q) {
      for (String i in LineSplitter().convert(q)) {
        //print(i);
        questions.add(i.split(','));
      }
    });
    //print(questions[0]);
    //questionMx = questions;
    return questions;
  }

  @override
  void initState() {
    controller1 = GifController(vsync: this);
    loadAsset().then((value) {
      questionMx = value;
    });
    answerMx = initAnswerMx();
    super.initState();
  }

  void _updateGif(String callerString) {
    setState(() {
      controller1.value = 0;
      controller1.animateTo(23,
          duration: Duration(milliseconds: (140 * 23).toInt()));
      if (callerString == 'question') {
        colorQuestion = Colors.orange;
        colorImage = Colors.white;
      }
      if (callerString == 'image') {
        colorImage = Colors.orange;
        colorQuestion = Colors.white;
      }
    });
  }

  void answerSelection(String userAnswer) {
    setState(() {
      String currentAns;
      currentAns = answerMx[currentQInfo.questionIndex - 1]
          [currentQInfo.subQuestionIndex];
      if (userAnswer == 'check') {
        if (currentAns == 'Yes') {
          answerMx[currentQInfo.questionIndex - 1]
              [currentQInfo.subQuestionIndex] = 'NoAns';
          cancelColor = Colors.grey;
          checkColor = Colors.grey;
        } else {
          answerMx[currentQInfo.questionIndex - 1]
              [currentQInfo.subQuestionIndex] = 'Yes';
          cancelColor = Colors.grey;
          checkColor = Colors.green;
        }
      }
      if (userAnswer == 'cancel') {
        if (currentAns == 'No') {
          answerMx[currentQInfo.questionIndex - 1]
              [currentQInfo.subQuestionIndex] = 'NoAns';
          cancelColor = Colors.grey;
          checkColor = Colors.grey;
        } else {
          answerMx[currentQInfo.questionIndex - 1]
              [currentQInfo.subQuestionIndex] = 'No';
          cancelColor = Colors.red;
          checkColor = Colors.grey;
        }
      }
    });
  }

  void updateQuestion(String action) {
    print('Q: ' + currentQInfo.questionIndex.toString());
    print('Sq: ' + currentQInfo.subQuestionIndex.toString());
    print(currentQInfo.subQuestionActive);
    //Check n question limit
    if ((currentQInfo.getQuestionIndex == 1) &&
        (currentQInfo.subQuestionIndex == 0) &&
        (action == 'back')) {
      return;
    }
    if ((currentQInfo.getQuestionIndex == questionMx.length - 1) &&
        (action == 'next')) {
      return;
    }
    //Check n subquestion limit
    if ((currentQInfo.subQuestionIndex == 1) && (action == 'back')) {
      currentQInfo.subQuestionActive = 'No';
      subQuestionActiveAux = 'No';
      currentQInfo.subQuestionIndex = 0;
      return;
    }
    if ((currentQInfo.subQuestionIndex > 2) && (action == 'next')) {
      currentQInfo.subQuestionActive = 'No';
      subQuestionActiveAux = 'No';
      currentQInfo.subQuestionIndex = 0;
    }

    // check next question cases
    if ((action == 'next') && (currentQInfo.subQuestionActive == 'No')) {
      currentQInfo.questionIndex++;
    }
    if ((action == 'next') && (currentQInfo.subQuestionActive == 'Yes')) {
      currentQInfo.subQuestionIndex++;
      while (questionMx[currentQInfo.questionIndex]
              [5 + currentQInfo.subQuestionIndex] ==
          '') {
        currentQInfo.subQuestionIndex++;
      }
      currentQInfo.subQuestionString =
          questionMx[0][5 + currentQInfo.subQuestionIndex];
      currentQInfo.buttonChoice = questionMx[currentQInfo.questionIndex]
          [5 + currentQInfo.subQuestionIndex];
    }
    if ((action == 'back') && (currentQInfo.subQuestionActive == 'No')) {
      currentQInfo.questionIndex--;
    }

    if ((action == 'back') && (currentQInfo.subQuestionActive == 'Yes')) {
      currentQInfo.subQuestionIndex--;
      while (questionMx[currentQInfo.questionIndex]
              [5 + currentQInfo.subQuestionIndex] ==
          '') {
        currentQInfo.subQuestionIndex--;
      }
      currentQInfo.subQuestionString =
          questionMx[0][5 + currentQInfo.subQuestionIndex];
      currentQInfo.buttonChoice = questionMx[currentQInfo.questionIndex]
          [5 + currentQInfo.subQuestionIndex];
    }

    currentQInfo.primaryQuestion = questionMx[currentQInfo.questionIndex][4];
    currentQInfo.imageName =
        'assets/images/' + questionMx[currentQInfo.questionIndex][3];
    currentQInfo.gifName =
        'assets/images/' + questionMx[currentQInfo.questionIndex][2];
    // Restore defaults
    checkColor = Colors.grey;
    cancelColor = Colors.grey;
    print('Q: ' + currentQInfo.questionIndex.toString());
    print('Sq: ' + currentQInfo.subQuestionIndex.toString());
    print(currentQInfo.subQuestionActive);
  }

  Widget renderInnerBody(QuestionInfo qInfo) {
    Widget aux;
    switch (qInfo.subQuestionActive) {
      case 'No':
        aux = Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Card(
              color: Colors.white,
              shadowColor: colorImage,
              elevation: 7,
              child: InkWell(
                onTap: () => _updateGif('image'),
                child: Image.asset(
                  qInfo.imageName,
                  fit: BoxFit.fill,
                ),
              ),
            ),
            Container(
              width: 90,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(Icons.cancel_rounded),
                    iconSize: 70,
                    color: (answerMx[currentQInfo.questionIndex - 1]
                                [currentQInfo.subQuestionIndex] ==
                            'No')
                        ? Colors.red
                        : Colors.grey,
                    onPressed: () {
                      subQuestionActiveAux = 'No';
                      answerSelection('cancel');
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.check_circle),
                    iconSize: 70,
                    color: (answerMx[currentQInfo.questionIndex - 1]
                                [currentQInfo.subQuestionIndex] ==
                            'Yes')
                        ? Colors.green
                        : Colors.grey,
                    onPressed: () {
                      subQuestionActiveAux = 'Yes';
                      answerSelection('check');
                    },
                  ),
                ],
              ),
            ),
          ],
        );
        break;
      case 'Yes':
        switch (currentQInfo.buttonChoice) {
          case 'N -DIA/MES/AÑO':
            aux = Column(
              children: [
                Container(
                  width: double.infinity,
                  height: 60,
                  margin: EdgeInsets.all(20),
                  child: Card(
                    color: Colors.white,
                    shadowColor: colorImage,
                    elevation: 7,
                    child: InkWell(
                      onTap: () => _updateGif('image'),
                      child: Center(
                        child: Text(
                          currentQInfo.subQuestionString,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Theme.of(context).primaryColorDark,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 220,
                      height: 150,
                      child: SpinBox(
                        textStyle: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 26,
                          color: Theme.of(context).primaryColorDark,
                        ),
                        value: 1,
                        min: 1,
                        //decoration: InputDecoration(labelText: 'Basic'),
                      ),
                      padding: const EdgeInsets.all(5),
                    ),
                    Container(
                      width: 100,
                      height: 50,
                      margin: EdgeInsets.all(10),
                      child: DropdownButton<String>(
                        value: dropdownValue,
                        icon: Icon(Icons.arrow_downward),
                        iconSize: 20,
                        elevation: 16,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Theme.of(context).primaryColorDark,
                        ),
                        underline: Container(
                          height: 3,
                          color: Theme.of(context).primaryColorLight,
                        ),
                        onChanged: (String newValue) {
                          setState(() {
                            dropdownValue = newValue;
                          });
                        },
                        items: <String>['Días', 'Meses', 'Años']
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ],
            );
            break;
          case 'SI/NO':
            aux = Column(
              children: [
                Container(
                  width: double.infinity,
                  height: 60,
                  margin: EdgeInsets.all(20),
                  child: Card(
                    color: Colors.white,
                    shadowColor: colorImage,
                    elevation: 7,
                    child: InkWell(
                      onTap: () => _updateGif('image'),
                      child: Center(
                        child: Text(
                          currentQInfo.subQuestionString,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Theme.of(context).primaryColorDark,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  width: double.infinity,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: Icon(Icons.cancel_rounded),
                        iconSize: 70,
                        color: (answerMx[currentQInfo.questionIndex - 1]
                                    [currentQInfo.subQuestionIndex] ==
                                'No')
                            ? Colors.red
                            : Colors.grey,
                        onPressed: () {
                          //subQuestionActiveAux = 'No';
                          answerSelection('cancel');
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.check_circle),
                        iconSize: 70,
                        color: (answerMx[currentQInfo.questionIndex - 1]
                                    [currentQInfo.subQuestionIndex] ==
                                'Yes')
                            ? Colors.green
                            : Colors.grey,
                        onPressed: () {
                          //subQuestionActiveAux = 'Yes';
                          answerSelection('check');
                        },
                      ),
                    ],
                  ),
                ),
              ],
            );
            break;
          case 'VECES - DIA/MES/AÑO':
            aux = Column(
              children: [
                Container(
                  width: double.infinity,
                  height: 60,
                  margin: EdgeInsets.all(20),
                  child: Card(
                    color: Colors.white,
                    shadowColor: colorImage,
                    elevation: 7,
                    child: InkWell(
                      onTap: () => _updateGif('image'),
                      child: Center(
                        child: Text(
                          currentQInfo.subQuestionString,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Theme.of(context).primaryColorDark,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 220,
                      height: 150,
                      child: SpinBox(
                        textStyle: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 26,
                          color: Theme.of(context).primaryColorDark,
                        ),
                        value: 1,
                        min: 1,
                      ),
                      padding: const EdgeInsets.all(5),
                    ),
                    Container(
                      width: 100,
                      height: 50,
                      margin: EdgeInsets.all(10),
                      child: DropdownButton<String>(
                        value: dropdownValue2,
                        icon: Icon(Icons.arrow_downward),
                        iconSize: 20,
                        elevation: 16,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Theme.of(context).primaryColorDark,
                        ),
                        underline: Container(
                          height: 3,
                          color: Theme.of(context).primaryColorLight,
                        ),
                        onChanged: (String newValue) {
                          setState(() {
                            dropdownValue2 = newValue;
                          });
                        },
                        items: <String>['al día', 'al mes', 'al año']
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ],
            );
            break;
          default:
            aux = Text('hola2');
        }
    }
    return aux;
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Antecedentes Personales'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            width: double.infinity,
            height: 70,
            margin: EdgeInsets.all(4),
            // decoration: BoxDecoration(
            //   border: Border.all(color: colorQuestion),
            // ),
            child: Card(
              elevation: 12,
              color: Colors.white,
              shadowColor: colorQuestion,
              child: InkWell(
                onTap: () => _updateGif('question'),
                child: Center(
                  child: Text(
                    questionMx == null
                        ? '¿Consume cigarrillo?'
                        : currentQInfo.primaryQuestion,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Theme.of(context).primaryColorDark,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Container(
            width: double.infinity,
            height: 270,
            margin: EdgeInsets.all(15),
            child: renderInnerBody(currentQInfo),
          ),
          Container(
            width: double.infinity,
            height: 170,
            margin: EdgeInsets.all(15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Card(
                  child: GifImage(
                    controller: controller1,
                    image: AssetImage(currentQInfo.gifName),
                    fit: BoxFit.fill,
                  ),
                  elevation: 7,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Row(
                      children: [
                        // IconButton(
                        //     icon: Icon(Icons.home_rounded),
                        //     iconSize: 50,
                        //     color: Colors.black,
                        //     onPressed: () {
                        //       return null;
                        //     }),
                        Container(
                          margin: EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey, width: 1.0),
                            color: Color.fromRGBO(220, 220, 220, 1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: IconButton(
                              icon: Icon(Icons.skip_previous_rounded),
                              iconSize: 50,
                              color: Colors.black,
                              onPressed: () {
                                setState(() {
                                  currentQInfo.subQuestionActive =
                                      subQuestionActiveAux;
                                  updateQuestion('back');
                                });
                              }),
                        ),
                        Container(
                          margin: EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey, width: 1.0),
                            color: Color.fromRGBO(220, 220, 220, 1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: IconButton(
                              icon: Icon(Icons.skip_next_rounded),
                              iconSize: 50,
                              color: Colors.black,
                              onPressed: () {
                                setState(() {
                                  currentQInfo.subQuestionActive =
                                      subQuestionActiveAux;
                                  updateQuestion('next');
                                  // if (currentQ < questionMx.length - 1) {
                                  //   currentQ++;
                                  // }
                                });
                              }),
                        ),
                      ],
                    ),
                    Container(
                      margin: EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey, width: 1.0),
                        color: Color.fromRGBO(220, 220, 220, 1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: IconButton(
                          icon: Icon(Icons.home_rounded),
                          iconSize: 50,
                          color: Colors.black,
                          onPressed: () {
                            return null;
                          }),
                    ),
                    // RaisedButton(
                    //   child: Text(
                    //     'OK',
                    //     style: TextStyle(
                    //         fontWeight: FontWeight.bold, fontSize: 18),
                    //   ),
                    //   color: Theme.of(context).primaryColor,
                    //   textColor: Theme.of(context).textTheme.button.color,
                    //   onPressed: _updateGif,
                    // )
                  ],
                )
                // Container(
                //   width: 120,
                //   child: Column(
                //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                //     crossAxisAlignment: CrossAxisAlignment.center,
                //     children: [
                //       IconButton(
                //           icon: Icon(Icons.cancel_rounded),
                //           iconSize: 70,
                //           color: Colors.red,
                //           onPressed: () {
                //             return null;
                //           }),
                //       IconButton(
                //           icon: Icon(Icons.check_circle),
                //           iconSize: 70,
                //           color: Colors.green,
                //           onPressed: () {
                //             return null;
                //           }),
                //     ],
                //   ),
                // ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
