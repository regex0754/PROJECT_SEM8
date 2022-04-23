import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import './constants.dart' as constants;

class currentFieldBar extends StatefulWidget implements PreferredSizeWidget {
  final double height;
  final ValueChanged<int> onTap;

  const currentFieldBar({
    Key? key,
    required this.height,
    required this.onTap,
  }) : super(key: key);

  @override
  _currentFieldBarState createState() => _currentFieldBarState();

  @override
  Size get preferredSize => Size.fromHeight(height);
}

class _currentFieldBarState extends State<currentFieldBar> {
  int fieldNumber = 0;

  final Color _selectedColor = Colors.white;
  final Color _unSelectedColor = Colors.black;

  @override
  Widget build(BuildContext context) {
    double _screenWidth = MediaQuery.of(context).size.width;
    return Container(
      height: widget.height,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,

        children: List.generate(constants.Constants.fieldNumber.length , (index) {
          return GestureDetector(
              child: Container(
                color: Theme.of(context).primaryColor,
                width: _screenWidth / constants.Constants.fieldNumber.length,
                height: widget.height,
                child: Stack(
                  children: <Widget>[
                    Align(
                      child: Icon(
                        Icons.grid_on,
                        color: fieldNumber == index ? _selectedColor : _unSelectedColor,
                      ),
                    ),
                    fieldNumber == index
                        ? Align(
                            alignment: Alignment.bottomCenter,
                            child: Container(
                              height: 2,
                              color: Colors.white,
                            ),
                          )
                        : SizedBox(),
                  ],
                ),
              ),
              onTap: () {
                if (fieldNumber != index) {
                  setState(() {
                    fieldNumber = index;
                    widget.onTap(index);
                  });
                }
              }
          );
        }),
        // children: <Widget>[
        //   GestureDetector(
        //       child: Container(
        //         color: Theme.of(context).primaryColor,
        //         width: _screenWidth / constants.Constants.fieldNumber.length,
        //         height: widget.height,
        //         child: Stack(
        //           children: <Widget>[
        //             Align(
        //               child: Icon(
        //                 Icons.grid_on,
        //                 color: fieldNumber == 0 ? _selectedColor : _unSelectedColor,
        //               ),
        //             ),
        //             fieldNumber == 0
        //                 ? Align(
        //                     alignment: Alignment.bottomCenter,
        //                     child: Container(
        //                       height: 2,
        //                       color: Colors.white,
        //                     ),
        //                   )
        //                 : SizedBox(),
        //           ],
        //         ),
        //       ),
        //       onTap: () {
        //         if (fieldNumber != 0) {
        //           setState(() {
        //             setFlags(tabName: constants.Constants.fieldNumber[fieldNumber].toString());
        //             widget.onTap(0);
        //           });
        //         }
        //       }
        //   ),
        //],
      ),
    );
  }
}