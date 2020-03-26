import 'package:flutter/material.dart';
import 'HomePage.dart';

void main()=> runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "India-Corona-Cases",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textTheme: Theme.of(context).textTheme.apply(
          bodyColor: Colors.black,
          displayColor: Colors.black,
          fontSizeFactor: 0.8,
        ),
        primaryColor: Color.fromRGBO(52, 58, 64, 1.0),accentColor: Color.fromRGBO(52, 58, 64, 1.0)),
      home: HomePage(),
    );
  }
}