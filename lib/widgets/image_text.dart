import 'package:flutter/material.dart';
import 'package:photo_editor_app/models/text_model.dart';

class ImageText extends StatelessWidget {
  final TextModel photoText;
  const ImageText({Key? key, required this.photoText}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      photoText.text,
      textAlign: photoText.textAlign,
      style: TextStyle(
          fontSize: photoText.fontSize,
          fontWeight: photoText.fontWeight,
          color: photoText.color,
      ),
    );
  }
}
