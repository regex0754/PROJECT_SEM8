import 'package:flutter/material.dart';

class myAnswer extends StatefulWidget implements PreferredSizeWidget {
  final double height;
  final Size screen;

  const myAnswer({
    Key? key,
    required this.height,
    required this.screen,
  }) : super(key: key);

  @override
  _myAnswerState createState() => _myAnswerState();

  @override
  Size get preferredSize => Size.fromHeight(height);
}

class _myAnswerState extends State<myAnswer> {
  final answerController = TextEditingController();

  @override
  void initState() {
    super.initState();
    answerController.addListener(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    double _screenWidth = MediaQuery.of(context).size.width;
    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            margin: EdgeInsets.symmetric(vertical: 8.0),
            height: 50.0,
            child: TextField(
              controller: answerController,
              decoration: InputDecoration(
                hintText: '',
                labelText: 'Your Answer',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.comment),
                suffixIcon: answerController.text.isEmpty ? Container(width: 0) : IconButton(
                                                                                icon: Icon(Icons.close),
                                                                                onPressed: () {
                                                                                  answerController.clear();
                                                                                },
                                                                              ),
                

              ),
              textInputAction: TextInputAction.done,
            ),
          ),
          SizedBox(
            width: widget.screen.width - 5, 
            height: 30,
            child: ElevatedButton(
              child: Text(
                'Submit',
                style: TextStyle(fontSize: 10),
              ),
              style: ElevatedButton.styleFrom(
                primary: Colors.green,
                padding: EdgeInsets.symmetric(horizontal: 3, vertical: 3),
                textStyle: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold
                          )
              ),
              onPressed: () {
                if (answerController.text.isEmpty){
                  return;
                }
                // POST the comment
                answerController.clear();
              },
            ),
          ),
        ]
      ),
    );
  }
}