import 'package:flutter/material.dart';
import 'package:photo_editor_app/utils/constants.dart';
import 'package:photo_editor_app/utils/my_routes.dart';
import 'package:photo_editor_app/utils/theme.dart';


void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: materialAppTitle,
      debugShowCheckedModeBanner: false,
      onGenerateRoute: MyRoutes.generateRoute,
      theme: myTheme(),
      initialRoute: welcomePage,
    );
  }
}

