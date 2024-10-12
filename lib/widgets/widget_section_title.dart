import 'package:flutter/material.dart';

Container widgetSectionTitle(String title, double leftPadding,
    [double pHeight = 45, double fontSize = 20, double topPadd = 10]) {
  return Container(
    height: pHeight,
    decoration: BoxDecoration(
      color: Colors.transparent,
      border: Border(
        bottom: BorderSide(
          width: 1,
          color: Colors.blueGrey[700] as Color,
        ),
      ),
    ),
    padding: EdgeInsets.only(left: 3, top: topPadd),
    margin: EdgeInsets.symmetric(horizontal: leftPadding),
    child: Center(
      child: Text(
        title,
        style: TextStyle(
          fontSize: fontSize,
          color: Colors.blueAccent[900],
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  );
}
