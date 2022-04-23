import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:project_sem8/main.dart' as mainFile;
import 'package:speech_to_text/speech_to_text.dart' as stt;
import './constants.dart' as constants;

class signupWidget extends StatefulWidget {
  const signupWidget({ Key? key }) : super(key: key);

  @override
  State<signupWidget> createState() => _signupWidgetState();
}

class _signupWidgetState extends State<signupWidget> {
  stt.SpeechToText _speech = stt.SpeechToText();
  
  late String userId = '';
  double _confidence = 1.0;
  String text = 'Hola';

  @override 
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) async {
      await startInteraction(); // changed
    });
  }

  Future startInteraction() async {
    userId = await mainFile.getData(constants.Constants.USER_ID);
    await mainFile.speak('Starting Interaction');
    if (!userId.isEmpty) {
      await mainFile.speak('Your current user id is ' + userId);
      await mainFile.speak('Do you want to change your userId ? Options are yes or no');
      int tries = 1, maxTries = 3;
      while (tries <= maxTries){
        await mainFile.speak('Try number ' + tries.toString());
        _listen();
        await Future.delayed(Duration(seconds: 5));
        _stopListening();
        tries++;
        if (text.isNotEmpty) {
          break;
        }
        if (tries < maxTries) {
          await mainFile.speak("Couldn't here anything. Please speak");
        }
      }

      if (text == 'yes'){
        await mainFile.speak('Speak your new user id');
        tries = 1; maxTries = 3;
        while (tries <= maxTries){
          await mainFile.speak('Try number ' + tries.toString());
          _listen();
          await Future.delayed(Duration(seconds: 5));
          _stopListening();
          tries++;
          if (text.isNotEmpty) {
            break;
          }
          if (tries < maxTries) {
            await mainFile.speak("Couldn't here anything. Please speak");
          }
        }
        if (!text.isEmpty) {
          await mainFile.speak('So you want to set your user id to ' + text);
          // changes in DATABASE and friendList
          await mainFile.updateData(constants.Constants.USER_ID, text);
        }
        else {
          await mainFile.speak("Was not able to listen. Please try again.");
        }
      }
      else {
        await mainFile.speak("You didn't choose option yes.");
      }
      await mainFile.speak('Exiting asking session');
    }
    else {
      await mainFile.speak('Do you want to set your userId ? Options are yes or no');
      int tries = 1, maxTries = 3;
      while (tries <= maxTries){
        await mainFile.speak('Try number ' + tries.toString());
        _listen();
        await Future.delayed(Duration(seconds: 5));
        _stopListening();
        tries++;
        if (text.isNotEmpty) {
          break;
        }
        if (tries < maxTries) {
          await mainFile.speak("Couldn't here anything. Please speak");
        }
      }

      if (text == 'yes'){
        await mainFile.speak('Speak your user id');
        tries = 1; maxTries = 3;
        while (tries <= maxTries){
          await mainFile.speak('Try number ' + tries.toString());
          _listen();
          await Future.delayed(Duration(seconds: 5));
          _stopListening();
          tries++;
          if (text.isNotEmpty) {
            break;
          }
          if (tries < maxTries) {
            await mainFile.speak("Couldn't here anything. Please speak");
          }
        }
        if (!text.isEmpty) {
          await mainFile.speak('So you want your user id to be ' + text);
          // changes in DATABASE and friendList
          await mainFile.saveData(constants.Constants.USER_ID, text);
        }
        else {
          await mainFile.speak("Was not able to listen. Please try again.");
        }
      }
      else {
        await mainFile.speak("You didn't choose option yes.");
      }
      await mainFile.speak('Exiting asking session');
    }
    await mainFile.speak('Ending Interaction');
    Navigator.pop(context);
  }

  Future<String> _listen() async {
    text = ''; // important
    bool available = await _speech.initialize(
      onStatus: (val) => print('onStatus: $val'),
      onError: (val) => print('onError: $val'),
    );
    if (available) {
      _speech.listen(
        onResult: (val) => setState(() {
          text = val.recognizedWords.toLowerCase();
          if (val.hasConfidenceRating && val.confidence > 0) {
            _confidence = val.confidence;
          }
        }),
      );
    }
    return text;
  }

  void _stopListening() {
    _speech.stop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Confidence: ${(_confidence * 100.0).toStringAsFixed(1)}%'),
      ),
      body: SingleChildScrollView(
        reverse: true,
        child: Container(
          padding: const EdgeInsets.fromLTRB(30.0, 30.0, 30.0, 150.0),
          child: RichText(
            text: TextSpan(
              text: text,
              style: DefaultTextStyle.of(context).style,
            ),
          ),
        ),
      ),
    );
  }
}