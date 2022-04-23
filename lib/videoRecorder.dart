import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:video_player/video_player.dart';
import 'package:path_provider/path_provider.dart';
import './main.dart' as mainFile;
import 'dart:io';

class videoRecorderPage extends StatefulWidget {
  final String itemId;
  const videoRecorderPage({
    Key? key,
    required this.itemId, 
  }) : super(key: key);

  @override
  State<videoRecorderPage> createState() => _videoRecorderPageState();
}

class _videoRecorderPageState extends State<videoRecorderPage> {
  bool cameraLoading = true;
  bool isRecording = false;
  late CameraController cameraController;

  @override
  void initState() {
    super.initState();
    initCamera();
    WidgetsBinding.instance!.addPostFrameCallback((_) async {
      await mainFile.speak("Starting to take video");
    });
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (cameraLoading) {
      return Container(
        color: Colors.white,
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    } else {
      return cameraRecordPage(cameraController: cameraController, itemId: widget.itemId);
      // return Container(
      //   child: Column(
      //     children: <Widget>[
      //       CameraPreview(
      //         cameraController,
      //         child: cameraRecordPage(
      //           cameraController: cameraController,
      //           itemId: widget.itemId
      //         ),
      //       ),
      //       // Container(
      //       //   height: 0,
      //       //   child: cameraRecordPage(
      //       //     cameraController: cameraController,
      //       //     itemId: widget.itemId
      //       //   ),
      //       // ),
      //     ],
      //   ),
      // );
    }
  }

  void initCamera() async {
    final cameras = await availableCameras();
    final back = cameras.firstWhere((camera) => camera.lensDirection == CameraLensDirection.back);
    cameraController = CameraController(back, ResolutionPreset.max);
    await cameraController.initialize();
    setState(() => cameraLoading = false);
  }

  // Future<XFile> recordVideo() async {
  //   if (isRecording) {
  //     await cameraController.stopVideoRecording();
  //     setState(() => isRecording = false);
  //   }
  //   await cameraController.prepareForVideoRecording();
  //   bool flag = true;
  //   while (flag){
  //     await cameraController.startVideoRecording();
  //     await Future.delayed(Duration(seconds: 5));
  //     flag = false;
  //   }
  //   setState(() => isRecording = true);
  //   final file = await cameraController.stopVideoRecording();
  //   setState(() => isRecording = false);
  //   return file;
  // }
}

class cameraRecordPage extends StatefulWidget {
  final CameraController cameraController;
  final String itemId;

  const cameraRecordPage({ 
    Key? key,
    required this.cameraController,
    required this.itemId,
  }) : super(key: key);

  @override
  State<cameraRecordPage> createState() => _cameraRecordPageState();
}

class _cameraRecordPageState extends State<cameraRecordPage> {
  @override
  void initState() {
    super.initState();
    // Future.delayed(
    //   Duration(seconds: 15),
    //   () async {
    //     Navigator.pop(context, await recordVideo());
    //   }
    // );
    WidgetsBinding.instance!.addPostFrameCallback((_) async {
      XFile video = await recordVideo();
      int L = await File(video.path).length();
      print("=====> Sizeee :: " + L.toString());
      Navigator.pop(context, video);
    });
  }

  @override
  Widget build(BuildContext context) {
    return CameraPreview(widget.cameraController);
  }

  Future<XFile> recordVideo() async {
    //await widget.cameraController.stopVideoRecording();
    await widget.cameraController.prepareForVideoRecording();

    // final Directory? appDirectory = await getExternalStorageDirectory(); //await getApplicationDocumentsDirectory();
    // if (appDirectory == null)
    //   return '';
    // final String videoDirectory = '${appDirectory.path}/Videos';
    // await Directory(videoDirectory).create(recursive: true);
    // String filePath = '$videoDirectory/${widget.itemId}.mp4';

    await widget.cameraController.startVideoRecording();
    return await Future.delayed(Duration(seconds: 10)).then((_) async {
      final videoFile = await widget.cameraController.stopVideoRecording();
      int L = await File(videoFile.path).length();
      print("=====> SizeeeLL :: " + L.toString());
      await mainFile.speak("video recording complete");
      return videoFile;
    });
  }
}