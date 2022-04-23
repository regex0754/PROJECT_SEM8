import 'package:chewie/chewie.dart';
import 'package:project_sem8/currentFieldBar.dart';
import 'package:project_sem8/myAnswer.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class HelpPage extends StatefulWidget {
  final String itemId, videoPath;
  const HelpPage({ 
    Key? key,
    required this.videoPath,
    required this.itemId,
  }) : super(key: key);

  @override
  State<HelpPage> createState() => _HelpPage();
}

class _HelpPage extends State<HelpPage> {
  late VideoPlayerController videoPlayerController;
  late ChewieController chewieController;
  int _pageIndex = 0;
  

  @override
  void initState() {
    super.initState();
    if (widget.videoPath.isEmpty){
      print("========> NULL");
    }
    videoPlayerController = VideoPlayerController.asset(widget.videoPath)
                            ..addListener(() => setState(() {}))
                            ..setLooping(true);
    chewieController = ChewieController(
      videoPlayerController: videoPlayerController,
      autoInitialize: true,
      aspectRatio: 16 / 9,
    );
  }

  @override
  void dispose() {
    videoPlayerController.dispose();
    chewieController.dispose();
    super.dispose();
  }

  Widget videoPlayer(Size screen) {
    return Container(
      padding: const EdgeInsets.only(left: 10, right: 10),
      color: Colors.black,
      height: screen.height / 2,
      child: Chewie(
        controller: chewieController,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var _screen = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text("Data regarding Item : " + widget.itemId),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            videoPlayer(_screen),
            Container(
              height: 3,
            ),
            currentFieldBar(
              height: 46, // make function(_screen)
              onTap: (value) {
                setState(() {
                  _pageIndex = value;
                });
              },
            ),
            Container(
              height: 3,
            ),
            myAnswer(
              height: 46, // make function(_screen)
              screen: _screen,
            ),
            Container(
              height: 3,
            ),
            GridView.count(
              childAspectRatio: 4/1, /// Important!!!
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              crossAxisCount: 1,
              crossAxisSpacing: 2,
              mainAxisSpacing: 2,
              children: List.generate(3, (index) { // LOAD from DATABASE
                  return Center(
                    child: SizedBox(
                      height: 50,
                      width: MediaQuery.of(context).size.width - 10,
                      child: ElevatedButton(
                        child: Text(
                          'answer no. ' + index.toString(),
                          style: TextStyle(fontSize: 15),
                        ),
                        style: ElevatedButton.styleFrom(
                          primary: Color.fromARGB(255, 155, 40, 40),
                          textStyle: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold
                                    )
                        ),
                        onPressed: () {
                          
                        },
                      )
                    ),
                  );
                }
              ),
            ),
          ]
        )
      )
    );
  }
}