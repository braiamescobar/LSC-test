import 'package:Lengua_senas_App/models/question_info.dart';
import 'package:flutter/material.dart';

class PrimaryQuestion extends StatelessWidget {
  final List answerMx;
  final QuestionInfo qInfo;
  final Function updateGif;
  final Function answerSelection;
  final Color colorImage;

  PrimaryQuestion({
    this.updateGif,
    this.qInfo,
    this.answerMx,
    this.answerSelection,
    this.colorImage,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Card(
          color: Colors.white,
          shadowColor: colorImage,
          elevation: 7,
          child: InkWell(
            onTap: () => updateGif('image'),
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
                color: (answerMx[qInfo.questionIndex - 1]
                            [qInfo.subQuestionIndex] ==
                        'No')
                    ? Colors.red
                    : Colors.grey,
                onPressed: () {
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
