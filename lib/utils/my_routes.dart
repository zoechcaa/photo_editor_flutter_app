import 'dart:io';
import 'package:flutter/material.dart';
import 'package:photo_editor_app/utils/constants.dart';
import 'package:photo_editor_app/screens/welcome_screen.dart';
import 'package:photo_editor_app/screens/photo_editing_screen.dart';
import 'package:photo_editor_app/screens/photo_selection_screen.dart';

class MyRoutes{
  static Route<dynamic> generateRoute(RouteSettings settings){
    switch(settings.name){
      case welcomePage:
        return MaterialPageRoute(builder: (context)=> const WelcomePage());
      case photoSelectionPage:
        return MaterialPageRoute(builder: (context)=> const PhotoSelectionPage());
      case editPhotoPage:
        File? image = settings.arguments as File?;
        return MaterialPageRoute(builder: (context) =>PhotoEditPage(image: image,));
    }
    return MaterialPageRoute(builder: (context) => const Scaffold(body: Text("no route defined"),) );
  }

}