import 'package:flutter/material.dart';
import "package:oru_app/fillcylinders.dart";

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.9,
        title: const Text('Day Scholars',
            style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w600,
                fontSize: 18)),
        actions: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: const [
              Text('Data Entry',
                  style: TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                      fontSize: 14)),
            ],
          ),
          IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.power_settings_new,
                color: Colors.redAccent,
              )),
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          color: Colors.white,
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(50, 200, 50, 1),
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const FillCylinders()));
            },
            style: ButtonStyle(
                backgroundColor: MaterialStateProperty.resolveWith((states) {
                  if (states.contains(MaterialState.pressed)) {
                    return Colors.black45;
                  }
                  return Colors.black;
                }),
                shape: MaterialStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                )),
            child: const Text('Fill Cylinders'),
          ),
        ),
      ),
    );
  }
}
