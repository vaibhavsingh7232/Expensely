import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class CustomBottomNavBar extends StatefulWidget {
  final int initialIndex;
  final Function(int) onTabSelected;

  const CustomBottomNavBar({
    super.key,
    required this.initialIndex,
    required this.onTabSelected,
  });

  @override
  CustomBottomNavBarState createState() => CustomBottomNavBarState();
}

class CustomBottomNavBarState extends State<CustomBottomNavBar> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex; // 🛠️ Fix: use passed index
  }

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    widget.onTabSelected(index);
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final bottomBarHeight = screenHeight * 0.13;
    final iconSize = screenHeight * 0.035;

    final icons = [
      Icons.home_outlined,
      Icons.receipt,
      Icons.bar_chart,
      Icons.calculate, // 🆕 Expense Splitter icon
      Icons.settings,
    ];

    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        Container(
          height: bottomBarHeight,
          decoration: const BoxDecoration(color: light80),
        ),
        BottomAppBar(
          color: Colors.transparent,
          shape: const CircularNotchedRectangle(),
          notchMargin: 8.0,
          child: Container(
            height: bottomBarHeight,
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(icons.length, (index) {
                return GestureDetector(
                  onTap: () => _onItemTapped(index),
                  child: Container(
                    width: iconSize * 2.2,
                    height: iconSize * 2.2,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentIndex == index
                          ? purple80
                          : Colors.transparent,
                    ),
                    child: Icon(
                      icons[index],
                      size:
                      _currentIndex == index ? iconSize * 1.5 : iconSize,
                      color: _currentIndex == index ? Colors.white : dark50,
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ],
    );
  }
}
