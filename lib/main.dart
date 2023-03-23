import 'package:flutter/material.dart';
import 'package:oru_app/homepage.dart';

import 'loginpage.dart';

void main(List<String> args) {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // ignore: prefer_const_constructors
    return MaterialApp(
      theme: ThemeData(
          appBarTheme:
              const AppBarTheme(backgroundColor: Colors.white, elevation: 1.0)),
      home: LoginPage(),
      debugShowCheckedModeBanner: false,
      title: 'QR Scanner',
    );
  }
}
