import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

class TextModel{
  String text;
  double left;
  double top;
  Color color;
  FontWeight fontWeight;
  double fontSize;
  TextAlign textAlign;

  TextModel({
    required this.text,
    required this.left,
    required this.top,
    required this.color,
    required this.fontWeight,
    required this.fontSize,
    required this.textAlign,
});

}
