import 'dart:convert';
import 'dart:async' show Future;

import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/material.dart';
import 'package:flutter_gifimage/flutter_gifimage.dart';

import '../models/question_info.dart';
import '../widgets/primaryQuestion.dart';
import '../widgets/secondaryNDiaMesAno.dart';
import '../widgets/secondarySiNo.dart';
import '../widgets/secondaryVecesDiaMesAno.dart';

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
        .loadString('assets/files/Antecedentes_test.csv')
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
    // Obtain N frames of current GIF
    List auxstr = currentQInfo.gifName.split('/');
    auxstr = auxstr.last.split('_');
    auxstr = auxstr.last.split('.');
    double maxVal = double.parse(auxstr[0])-1;
    print(maxVal);
    setState(() {
      controller1.value = 0;
      controller1.animateTo(maxVal,
          duration: Duration(milliseconds: (140 * maxVal).toInt()));
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

  void answerSelection(String userAnswer, String subQActiveAux) {
    setState(() {
      String currentAns;
      subQuestionActiveAux = subQActiveAux;
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

  renderInnerBody(QuestionInfo qInfo) {
    switch (qInfo.subQuestionActive) {
      case 'No':
        return PrimaryQuestion(
          updateGif: _updateGif,
          answerSelection: answerSelection,
          answerMx: answerMx,
          colorImage: colorImage,
          qInfo: qInfo,
        );
        break;
      case 'Yes':
        switch (currentQInfo.buttonChoice) {
          case 'N -DIA/MES/AÑO':
            return NDiaMesAno(
              colorImage: colorImage,
              qInfo: qInfo,
              updateGif: _updateGif,
            );
            break;
          case 'SI/NO':
            return SiNo(
              updateGif: _updateGif,
              answerSelection: answerSelection,
              answerMx: answerMx,
              colorImage: colorImage,
              qInfo: qInfo,
            );
            break;
          case 'VECES - DIA/MES/AÑO':
            return  VecesDiaMesAno(
              colorImage: colorImage,
              qInfo: qInfo,
              updateGif: _updateGif,
            );
            break;
          default:
            return Text('hola2');
        }
    }
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
                        ? 'Xonsume cigarrillo?'
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
                                  controller1.value = 1;
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
                                  controller1.value = 1;
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
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
