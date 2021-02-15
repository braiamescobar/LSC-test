import 'package:flutter/material.dart';
import 'package:flutter_spinbox/material.dart';

import '../models/question_info.dart';

class VecesDiaMesAno extends StatefulWidget {
  final QuestionInfo qInfo;
  final Function updateGif;
  final Color colorImage;

  VecesDiaMesAno({this.colorImage, this.updateGif, this.qInfo});

  @override
  _VecesDiaMesAnoState createState() => _VecesDiaMesAnoState();
}

class _VecesDiaMesAnoState extends State<VecesDiaMesAno> {
    String dropdownValue = 'al día';
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
            shadowColor: widget.colorImage,
            elevation: 7,
            child: InkWell(
              onTap: () => widget.updateGif('image'),
              child: Center(
                child: Text(
                  widget.qInfo.subQuestionString,
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
  }
}
