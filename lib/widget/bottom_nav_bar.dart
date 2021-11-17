import 'package:flutter/material.dart';
import 'package:oil_palm_system/res/constant.dart';

class BottomNavBar extends StatelessWidget {
  final int index;
  final Function(int) itemTapped;
  const BottomNavBar({Key? key, required this.index, required this.itemTapped})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: '通知',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.landscape),
          label: '园地',
        ),
      ],
      currentIndex: index,
      selectedItemColor: Constant.themeColor,
      onTap: itemTapped,
    );
  }
}
