import 'package:flutter/material.dart';
import "package:oru_app/fillcylinders.dart";
import 'package:oru_app/reusables.dart';

class HomePage extends StatefulWidget {
  String access_token;
  HomePage({Key? mykey, required this.access_token}) : super(key: mykey);

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
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(
                Icons.power_settings_new,
                color: Colors.redAccent,
              )),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(children: [
          SizedBox(
            height: 100,
          ),
          Container(
            color: Colors.white,
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(50, 10, 50, 1),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => FillCylinders(
                              qrList: [],
                              accessToken: widget.access_token,
                            )));
              },
              style: ButtonStyle(
                  minimumSize: MaterialStateProperty.all(Size.fromHeight(45)),
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

          //all buttons below are dummy ,does not work

          SizedBox(
            height: 25,
          ),
          Kbutton("Deliver Cylinders ", () => () {}),

          SizedBox(
            height: 25,
          ),
          Kbutton("Pickup ", () => () {}),
          SizedBox(
            height: 25,
          ),
          Kbutton("Unloading ", () => () {}),
          SizedBox(
            height: 25,
          ),
          Kbutton("Manual ", () => () {}),
          SizedBox(
            height: 25,
          ),
          Kbutton("Add New Cylinder ", () => () {}),
          SizedBox(
            height: 25,
          ),
        ]),
      ),
    );
  }
}
