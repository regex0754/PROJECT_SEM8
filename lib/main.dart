import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:project_sem8/HelpSection.dart';
import 'package:project_sem8/sign_up.dart';
import 'package:project_sem8/videoRecorder.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:barcode_scan/barcode_scan.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'dart:async';
import './constants.dart' as constants;
import 'package:camera/camera.dart';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:project_sem8/apis/firebase_api';

final FlutterTts flutterTts = FlutterTts();
final int MAX_ID_COUNT = 10000;

Future<void> speak(String text, {double speechRate = 0.5}) async {
  // make a fun in speech class so that when we speak, we first disable listening
  // using :: setState(() => _isListening = false); _speech.stop();
  await flutterTts.setSpeechRate(speechRate);
  await flutterTts.awaitSpeakCompletion(true);
  await flutterTts.setLanguage("en-US");
  await flutterTts.setPitch(1); // range : [0.5 , 1.5]
  await flutterTts.speak(text);
}

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Let\'s Talk',
      theme: ThemeData(
        primarySwatch: Colors.red, 
      ),
      home: Scaffold(
        body: Center(child: BarCodePage()),
      ),
    );
  }
}

class BarCodePage extends StatefulWidget {
  @override
  BarcodeScannerPage createState() {
    return new BarcodeScannerPage();
  }
}

class BarcodeScannerPage extends State<BarCodePage>{
  String result = "Start Scanning!";

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("QR Scanner"),
      ),
      body: Center(
        child: Text(
          result,
          style: new TextStyle(fontSize: 30.0, fontWeight: FontWeight.bold),
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            heroTag: 'btn1',
            icon: Icon(Icons.camera_alt),
            label: Text("Scan"),
            onPressed: () {
              _scanQR().then((scanedWithOutError) {
                if (scanedWithOutError){
                  if (!result.isEmpty) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => BarcodeOptionsPage(id: result))
                    );
                  }
                }
                else{
                  speak("Some error occured during scanning. Please scan again");
                }
              });
            },
          ),
          SizedBox(
            height: 10,
          ),
          FloatingActionButton.extended(
            heroTag: 'btn2',
            icon: FaIcon(FontAwesomeIcons.signInAlt),
            label: Text("Sign In"),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => signupWidget()),
              );
            },
          ),
          SizedBox(
            height: 10,
          ),
          FloatingActionButton.extended(
            heroTag: 'btn3',
            icon: Icon(Icons.help),
            label: Text("Help"),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HelpSection(profileId: 'random')), // change this to 'friend's id whom you want to help'
              );
            },
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Future<bool> _scanQR() async {
    try {
      ScanResult qrScanResult = await BarcodeScanner.scan(options: ScanOptions(
        autoEnableFlash: true,
      ))
      .timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          return null;
        }
      );
      String qrResult = qrScanResult == null ? '' : qrScanResult.rawContent;
      setState(() {
        result = qrResult;
      });
      return true;
    } on PlatformException catch (ex) {
      if (ex.code == BarcodeScanner.cameraAccessDenied) {
        setState(() {
          result = "Camera permission was denied";
        });
      } else {
        setState(() {
          result = "Unknown Error $ex";
        });
      }
    } on FormatException {
      setState(() {
        result = "You pressed the back button before scanning anything";
      });
    } catch (ex) {
      setState(() {
        result = "Unknown Error $ex";
      });
    }
    return false;
  }
}

Future<void> saveData(String id, String data) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString(id, data);
}

Future<String> getData(String id) async {
  if (!await dataAvailable(id)){
    return '';
  }
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? value = prefs.getString(id); 
  return value ?? ''; // null check for myList
}

Future<void> deleteData(String id) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  if (prefs.containsKey(id)){
    await prefs.remove(id);
  }
}

Future<void> updateData(String id, String data) async {
  await deleteData(id);
  await saveData(id, data);
}

Future<bool> dataAvailable(String id) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  if (prefs.containsKey(id)){
    return true;
  }
  return false;
}

class BarcodeOptionsPage extends StatefulWidget {
  final String id;
  const BarcodeOptionsPage({
    Key? key,
    required this.id,
  }) : super(key: key);

  @override
  _BarcodeOptionsPageState createState() => _BarcodeOptionsPageState();
}

class _BarcodeOptionsPageState extends State<BarcodeOptionsPage>{
  stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  String _text = 'Press the button and start speaking';
  double _confidence = 1.0;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    WidgetsBinding.instance!.addPostFrameCallback((_) async {
      await startInteraction(); // changed
    });
  }

  @override
  void dispose() {
    _speech.stop();
    super.dispose();
  }

  bool checkId(String id) {
    try{
      int number = int.parse(id);
      return (number >= 0 && number < MAX_ID_COUNT);
    } on FormatException {
      return false;
    }
  }

  Future<void> startInteraction() async {
    String userId = await getData(constants.Constants.USER_ID);
    if (userId.isEmpty){
      await speak('Please set your user id');
      await speak("ending interaction");
      _text = 'Scan again';
      Navigator.pop(context);
      return;
    }

    await speak("starting interaction");
    await dataAvailable(widget.id).then((available) async {
      if (available){
        await speak("Data is available");
        // get/ delete/ set data
        await getData(widget.id).then((data) async {
          if (data.length != constants.Constants.fieldNumber.length){
            await speak("Error occured during fetching the details");
          }
          else{
            while (true){
              await speak("What do you want to know?");
              await speak("options are :");
              await speak("1. name");
              await speak("2. manufacture date");
              await speak("3. expiry date");
              await speak("4. description");
              await speak("5. reminder");
              
              int triesCounter = 0;
              _text = '';
              while (_text == '' && triesCounter < 3){
                await speak("Try number " + triesCounter.toString());
                if (triesCounter > 0){
                  await speak("Couldn't hear anything. Please speak!");
                }
                triesCounter++;
                print("before : " + _text);
                await _listen();
                print("after : " + _text);
                await Future.delayed(Duration(seconds: 5));
              }
              setState(() => _isListening = false);
              _speech.stop();

              await speak("So you want to know, " + _text);

              if (constants.Constants.fieldNumber.containsKey(_text)){
                await speak(_text + "is" + data[constants.Constants.fieldNumber[_text] ?? 0], speechRate: 0.25);
              }
              else{
                await speak("Couldn't find such field");
              }

              // asking if he/she want to continue
              await speak("Do you want to know anything more?");
              await speak("Options are yes or no");
              triesCounter = 0;
              _text = '';
              while (_text == '' && triesCounter < 3){
                await speak("Try number " + triesCounter.toString());
                if (triesCounter > 0){
                  await speak("Couldn't hear anything. Please speak!");
                }
                triesCounter++;
                print("before : " + _text);
                await _listen();
                print("after : " + _text);
                await Future.delayed(Duration(seconds: 5));
              }
              setState(() => _isListening = false);
              _speech.stop();
              if (_text != "yes"){
                await speak("Exiting asking session");
                break;
              }
            }
          }
        });
      }
      else{
        await speak("No data available for this barcode");
        if (checkId(widget.id)){
          await speak("Do you want to set data for this barcode ?");
          await speak("Options are yes or no. Choose one of them");

          int triesCounter = 0;
          _text = '';
          while (_text == '' && triesCounter < 3){
            await speak("Try number " + triesCounter.toString());
            if (triesCounter > 0){
              await speak("Couldn't hear anything. Please speak!");
            }
            triesCounter++;
            await _listen();
            await Future.delayed(Duration(seconds: 5));
          }
          setState(() => _isListening = false);
          _speech.stop();

          if (_text == 'yes'){
            await speak("Preparing to take the video.");
            XFile video = await Navigator.push(context, MaterialPageRoute(builder: (context) => videoRecorderPage(itemId: widget.id)));

            int L = await File(video.path).length();
            print("=====> Size :: " + L.toString());

            String destination = 'profile/' + userId + '/' + widget.id + '/videoFiles/video.mp4';
            UploadTask? task = FirebaseApi.uploadFile(destination, File(video.path));
            if (task == null) {
              await speak("Couldn't save the video file. Please try scanning again.");
            }
            else {
              final snapShot = await task.whenComplete(() {});
              final urlDownload = await snapShot.ref.getDownloadURL();
              // do smomething
            }
            File(video.path).deleteSync();
          }
          else if (_text == 'no'){
            await speak("Returning to scanning page");
          }
          else{
            await speak("Error occured while listening. Please scan again");
          }
        }
        else{
          await speak("Can't use this barcode");
        }
      }
    });
    await speak("ending interaction");
    _text = 'Scan again';
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Confidence: ${(_confidence * 100.0).toStringAsFixed(1)}%'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: AvatarGlow(
        animate: _isListening,
        glowColor: Theme.of(context).primaryColor,
        endRadius: 75.0,
        duration: const Duration(milliseconds: 2000),
        repeatPauseDuration: const Duration(milliseconds: 100),
        repeat: true,
        child: FloatingActionButton(
          onPressed: () async {
            await _listen();
          },
          child: Icon(_isListening ? Icons.mic : Icons.mic_none),
        ),
      ),
      body: SingleChildScrollView(
        reverse: true,
        child: Container(
          padding: const EdgeInsets.fromLTRB(30.0, 30.0, 30.0, 150.0),
          child: RichText(
            text: TextSpan(
              text: _text,
              style: DefaultTextStyle.of(context).style,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) => print('onStatus: $val'),
        onError: (val) => print('onError: $val'),
      );
      if (available) {
        _text = '';
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) => setState(() {
            _text = val.recognizedWords.toLowerCase();
            if (val.hasConfidenceRating && val.confidence > 0) {
              _confidence = val.confidence;
            }
          }),
        );
      }
    }
    else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }
}