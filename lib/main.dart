import 'package:flutter/material.dart';
//import 'package:giffinder/ui/home_page.dart';
import 'package:giffinder/ui/home_page.dart';

void main() {
  runApp(MaterialApp(
    home: HomePage(),
    theme: ThemeData(
        inputDecorationTheme: const InputDecorationTheme(
      focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.blueAccent)),
      enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
      labelStyle: TextStyle(color: Colors.white),
      hintStyle: TextStyle(color: Colors.white),
    )),
  ));
}
