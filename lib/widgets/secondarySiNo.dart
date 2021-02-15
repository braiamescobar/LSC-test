import 'package:flutter/material.dart';
import '../models/question_info.dart';

class SiNo extends StatelessWidget {
  final List answerMx;
  final QuestionInfo qInfo;
  final Function updateGif;
  final Function answerSelection;
  final Color colorImage;

  SiNo({
    this.updateGif,
    this.qInfo,
    this.answerMx,
    this.answerSelection,
    this.colorImage,
  });
  @override
  Widget build(BuildContext context) {
    return Column(
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
              onTap: () => updateGif('image'),
              child: Center(
                child: Text(
                  qInfo.subQuestionString,
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
                color: (answerMx[qInfo.questionIndex - 1]
                            [qInfo.subQuestionIndex] ==
                        'No')
                    ? Colors.red
                    : Colors.grey,
                onPressed: () {
                  //subQuestionActiveAux = 'No';
                  answerSelection('cancel', 'No');
                },
              ),
              IconButton(
                icon: Icon(Icons.check_circle),
                iconSize: 70,
                color: (answerMx[qInfo.questionIndex - 1]
                            [qInfo.subQuestionIndex] ==
                        'Yes')
                    ? Colors.green
                    : Colors.grey,
                onPressed: () {
                  //subQuestionActiveAux = 'Yes';
                  answerSelection('check', 'Yes');
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
