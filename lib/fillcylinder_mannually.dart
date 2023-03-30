// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:oru_app/fillcylinders.dart';
import 'package:oru_app/functions.dart';

import 'package:oru_app/reusables.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class FillMannually extends StatefulWidget {
  String accessToken;

  FillMannually({super.key, Key? mykey, required this.accessToken});

  @override
  State<FillMannually> createState() => _FillMannuallyState();
}

class _FillMannuallyState extends State<FillMannually> {
  TextEditingController cylinderNumber = TextEditingController();
  List<String> cylinderTypes = [];
  List<String> customerName = [];
  String dropDownvalueCylinder = "";
  String dropDownvalueCustomer = "Select Customer";
  List customerID = [];
  List cylinderTypeId = [];
  TextEditingController cylinderController = TextEditingController();
  TextEditingController customerController = TextEditingController();

  List cylinderNumbersTyped = [];
  List cylinderTypesTyped = [];

  List cylinderID = [];

  bool cancel = false;

  @override
  void initState() {
    super.initState();

    fetchCylinderDetails();
    fetchCustomerDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Fill Cylinders manually",
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            reusableTextField(
                "Cylinder Number", Icons.arrow_right, false, cylinderNumber),
            const SizedBox(
              height: 30,
            ),
            TypeAheadField(
              textFieldConfiguration: TextFieldConfiguration(
                  decoration: InputDecoration(
                    hintText: dropDownvalueCylinder,
                    border: OutlineInputBorder(),
                    labelText: "Cylinder Types",
                  ),
                  controller: cylinderController),
              suggestionsCallback: (String pattern) async {
                return cylinderTypes
                    .where((item) =>
                        item.toLowerCase().contains(pattern.toLowerCase()))
                    .toList();
              },
              itemBuilder: (BuildContext context, String suggestion) {
                return ListTile(
                  title: Text(suggestion),
                );
              },
              onSuggestionSelected: (String suggestion) {
                setState(() {
                  dropDownvalueCylinder = suggestion;
                  cylinderController.text = suggestion;
                });
              },
            ),
            SizedBox(
              height: 60,
            ),
            TypeAheadField(
              textFieldConfiguration: TextFieldConfiguration(
                  decoration: InputDecoration(
                    hintText: dropDownvalueCustomer,
                    border: OutlineInputBorder(),
                    labelText: "Customer",
                  ),
                  controller: customerController),
              suggestionsCallback: (String pattern) async {
                return customerName
                    .where((item) =>
                        item.toLowerCase().contains(pattern.toLowerCase()))
                    .toList();
              },
              itemBuilder: (BuildContext context, String suggestion) {
                return ListTile(
                  title: Text(suggestion),
                );
              },
              onSuggestionSelected: (String suggestion) {
                setState(() {
                  dropDownvalueCustomer = suggestion;
                  customerController.text = suggestion;
                });
              },
            ),
            const SizedBox(
              height: 30,
            ),
            buttons(context, "Add", () {
              if (cylinderNumber.text != "" && dropDownvalueCylinder != "") {
                setState(() {
                  cylinderNumbersTyped.add(cylinderNumber.text);
                  cylinderTypesTyped.add(dropDownvalueCylinder);
                });
              }
            }),
            SizedBox(
              height: 10,
            ),
            ListView.builder(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemCount: cylinderNumbersTyped.length,
                itemBuilder: (context, index) {
                  return Column(
                    children: [
                      Card(
                        elevation: 2,
                        child: ListTile(
                          title: Text(cylinderNumbersTyped[index]),
                          subtitle: Text(cylinderTypesTyped[index]),
                          tileColor: Colors.white70,
                          trailing: GestureDetector(
                            onTap: () {
                              setState(() {
                                cylinderNumbersTyped.removeAt(index);
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
            buttons(context, "Submit", () {
              for (int i = 0; i < cylinderNumbersTyped.length; i++) {
                fetchCylinderIdMannually(
                    widget.accessToken,
                    cylinderNumbersTyped[i],
                    cylinderTypeId[
                        cylinderTypes.indexOf(cylinderTypesTyped[i])]);
              }
              makePostRequestToFill(widget.accessToken, cylinderID, 40);

              setState(() {
                if (cylinderNumbersTyped.isNotEmpty) {
                  cancel = true;
                } else {
                  cancel = false;
                }
                cylinderID.clear();
                cylinderNumbersTyped.clear();
                cylinderTypesTyped.clear();
              });
            }),
            SizedBox(
              height: 15,
            ),
            cancel
                ? buttons(context, "cancel", () {
                    setState(() {
                      cylinderID.clear();
                      cylinderNumbersTyped.clear();
                      cylinderTypesTyped.clear();
                      cancel = false;
                    });
                  })
                : Divider(),
            buttons(context, "Done", () {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => FillCylinders(
                          qrList: [], accessToken: widget.accessToken)));
            }),
          ],
        ),
      ),
    );
  }

  //--------------------------------------------------------------------------
  //API Functions below

  Future<void> fetchCylinderDetails() async {
    const url = 'http://soc-erp.showcase.code7.in/api/cylinder-types';
    final token = widget.accessToken;
    final response = await http.get(Uri.parse(url), headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    });
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      for (Map i in data['types']) {
        cylinderTypes.add(i['name']);
        cylinderTypeId.add(i['id']);
      }
    } else {
      // Handle error
    }
  }

  Future<void> fetchCustomerDetails() async {
    const url = 'http://soc-erp.showcase.code7.in/api/customers';
    final token = widget.accessToken;
    final response = await http.get(Uri.parse(url), headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    });
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      for (Map i in data['customers']) {
        customerName.add(i['name']);
        customerID.add(i['id']);
      }
    } else {
      // Handle error
    }
  }

  Future<void> fetchCylinderIdMannually(
      String accessToken, String number, int type) async {
    String types = type.toString();
    final String apiUrl =
        'http://soc-erp.showcase.code7.in/api/cylinder?number=$number&type=$types';

    final response = await http.get(Uri.parse(apiUrl), headers: {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    });

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      cylinderID.add(data['cylinder']['id']);

      // print(cylinderID);
      // Process data
    } else {
      toast("Cylinder number and type does not match");
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

      //print('Response status: ${response.statusCode}');
      if (response.statusCode != 200) {
        toast("Error in make postreq to fill in mannully page");
      } else {
        toast("submitted");
        setState(() {});
      }
    }
  }
}
