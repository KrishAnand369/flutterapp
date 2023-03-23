// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:oru_app/fillcylinders.dart';

import 'package:oru_app/reusables.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class FillMannually extends StatefulWidget {
  String accessToken;
  List qrList;
  FillMannually(
      {super.key, Key? mykey, required this.qrList, required this.accessToken});

  @override
  State<FillMannually> createState() => _FillMannuallyState();
}

class _FillMannuallyState extends State<FillMannually> {
  TextEditingController cylinderNumber = TextEditingController();
  List<String> cylinderTypes = [];
  List<String> customer = [];
  String dropDownvalueCylinder = "Select Cylinder type";
  String dropDownvalueCustomer = "Select Customer";

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
          "Add Cylinder",
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
            const Text("Cylinder Type"),
            DropdownButton<String>(
              items: cylinderTypes.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  dropDownvalueCylinder = value.toString();
                });
              },
              hint: Text(dropDownvalueCylinder),
              dropdownColor: const Color.fromARGB(255, 255, 255, 255),
              style: const TextStyle(color: Colors.black),
              borderRadius: const BorderRadius.all(Radius.elliptical(10, 10)),
            ),
            const SizedBox(
              height: 30,
            ),
            const Text("Customer"),
            DropdownButton<String>(
              items: customer.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(
                    value,
                    maxLines: null,
                    overflow: TextOverflow.visible,
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  dropDownvalueCustomer = value.toString();
                });
              },
              hint: Text(
                dropDownvalueCustomer,
              ),
              dropdownColor: const Color.fromARGB(255, 255, 255, 255),
              style: const TextStyle(color: Colors.black),
              borderRadius: const BorderRadius.all(Radius.elliptical(10, 10)),
              elevation: 4,
            ),
            const SizedBox(
              height: 30,
            ),
            buttons(context, "Add", () {
              widget.qrList.add(cylinderNumber.text);
            }),
            SizedBox(
              height: 30,
            ),
            buttons(context, "Submit", () {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => FillCylinders(
                          qrList: widget.qrList,
                          accessToken: widget.accessToken)));
            }),
          ],
        ),
      ),
    );
  }

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
        customer.add(i['name']);
      }
    } else {
      // Handle error
    }
  }
}
