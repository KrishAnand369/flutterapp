import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:oru_app/fillcylinder_mannually.dart';
import 'package:oru_app/functions.dart';
import 'package:oru_app/scanner.dart';
import 'package:http/http.dart' as http;

class FillCylinders extends StatefulWidget {
  List qrList;

  String accessToken;

  FillCylinders({Key? mykey, required this.qrList, required this.accessToken})
      : super(key: mykey);

  @override
  State<FillCylinders> createState() => _FillCylindersState();
}

class _FillCylindersState extends State<FillCylinders> {
  List cylinderId = [];
  bool flag = false;
  bool cancel = false;

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
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          IconButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => Scanner(
                              accessToken: widget.accessToken,
                              qrList: widget.qrList,
                            )));
              },
              icon: const Icon(
                Icons.qr_code_scanner,
                size: 50,
              ),
              alignment: Alignment.topCenter),

          const SizedBox(
            height: 30,
          ),

          // Text("${widget.qrList[0]}")
          ListView.builder(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              itemCount: widget.qrList.length,
              itemBuilder: (context, index) {
                return Column(
                  children: [
                    Card(
                      elevation: 2,
                      child: ListTile(
                        title: Text(widget.qrList[index]),
                        subtitle: Text((index + 1).toString()),
                        tileColor: Colors.white70,
                        trailing: GestureDetector(
                          onTap: () {
                            setState(() {
                              widget.qrList.removeAt(index);
                            });
                          },
                          child: Icon(
                            Icons.remove_circle,
                            color: Colors.red[700],
                            size: 30,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    )
                  ],
                );
              }),
          ElevatedButton(
            onPressed: () {
              update();
              if (flag) {
                toast("some QR codes are not valid");
              }
              makePostRequestToFill(widget.accessToken, cylinderId, 40);

              flag = false;
              cylinderId.clear();
              if (widget.qrList.isEmpty) {
                setState(() {
                  cancel = false;
                });
              }
            },
            child: const Text(
              "Submit",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(
            height: 20,
          ),

          cancel
              ? ElevatedButton(
                  onPressed: () {
                    setState(() {
                      cylinderId.clear();
                      cancel = false;
                    });
                  },
                  child: Text("Cancel"),
                  style: ButtonStyle(),
                )
              : Text(""),
          Divider(thickness: 1),

          SizedBox(
            height: 10,
          ),

          Card(
            elevation: 2,
            child: ListTile(
              title: Text("Manual Entries"),
              leading: Icon(
                Icons.add,
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => FillMannually(
                            accessToken: widget.accessToken,
                          )),
                );
              },
              tileColor: Colors.white,
            ),
          )
        ],
      ),
    );
  }

  void update() {
    for (int i = 0; i < widget.qrList.length; i++) {
      fetchCylinderByQr(widget.qrList[i]);
    }
    setState(() {
      cancel = true;
    });
  }

  Future fetchCylinderByQr(String qrId) async {
    String url = 'http://soc-erp.showcase.code7.in/api/cylinder/qr';
    url += '?qr_id=$qrId';
    final token = widget.accessToken;
    http.Response response = await http.get(Uri.parse(url), headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    });
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      setState(() {
        cylinderId.add(data["cylinder"]["id"]);
        widget.qrList.remove(qrId);
      });
      print(cylinderId);
    } else {
      flag = true;
    }
  }

  void makePostRequestToFill(
      String accessToken, List cylinderId, int purity) async {
    if (!cylinderId.isEmpty) {
      var url = Uri.parse('http://soc-erp.showcase.code7.in/api/fill');

      var requestBody = jsonEncode({
        "purity": purity,
        "cylinders": cylinderId,
        "manual-cylinders": [],
        "remarks": "string"
      });

      var response = await http.post(url, body: requestBody, headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json'
      });

      print('Response status: ${response.statusCode}');
      if (response.statusCode != 200) {
        toast("Error");
      } else {
        toast("submitted");
        setState(() {
          cancel = false;
        });
      }
    }
  }
}
