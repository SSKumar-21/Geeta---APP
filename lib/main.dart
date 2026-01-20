import 'package:flutter/material.dart';
import 'package:geeta2/Splash.dart';

void main(){
  runApp(Geeta());
}

class Geeta extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue
      ),
      home: Splash(),
    );
  }
}

