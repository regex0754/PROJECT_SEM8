import 'package:flutter/material.dart';
import 'package:project_sem8/HelpPage.dart';

class HelpSection extends StatefulWidget {
  final String profileId;
  const HelpSection({ 
    Key? key,
    required this.profileId,
  }) : super(key: key);

  @override
  State<HelpSection> createState() => _HelpSectionState();
}

class _HelpSectionState extends State<HelpSection> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink,
      appBar: AppBar(
        title: Text('Help Section'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
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
                          'Item ' + index.toString(),
                          style: TextStyle(fontSize: 24),
                        ),
                        style: ElevatedButton.styleFrom(
                          primary: Colors.black,
                          textStyle: TextStyle(
                                      fontSize: 30,
                                      fontWeight: FontWeight.bold
                                    )
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                return HelpPage(
                                  itemId: index.toString(),
                                  videoPath: 'assets/rickRoll.mp4',
                                );
                              },
                            ),
                          );
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
