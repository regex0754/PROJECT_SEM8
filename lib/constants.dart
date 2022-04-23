import 'package:flutter/cupertino.dart';
import 'package:flutter_icons/flutter_icons.dart';

class Constants {
  static const String USER_ID ='user_id';
  static const String name = 'name', manufactureDate = 'manufacture date', expiryDate = 'expiry date', description = 'description', reminder = 'reminder';  
  static const Map<String, int> fieldNumber = <String, int>{
    name: 0,
    manufactureDate: 1,
    expiryDate: 2,
    description: 3,
    reminder: 4
  };
  //static List<IconData> iconList = [Icons.grid_on, Icons.grid_on, Icons.grid_on, Icons.grid_on, Icons.grid_on];
}