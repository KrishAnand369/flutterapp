import 'package:flutter/material.dart';
import 'package:oru_app/scanner.dart';

class FillCylinders extends StatefulWidget {
  const FillCylinders({super.key});

  @override
  State<FillCylinders> createState() => _FillCylindersState();
}

class _FillCylindersState extends State<FillCylinders> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Fill Cylinders',
          style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.4),
        ),
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(
            Icons.arrow_back_sharp,
            size: 25,
            color: Colors.black,
          ),
        ),
      ),
      body: Row(mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            IconButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const Scanner()));
                },
                icon: const Icon(Icons.qr_code_scanner, size: 50,),alignment: Alignment.topRight),
          ],
        ),
      
    );
  }
}
