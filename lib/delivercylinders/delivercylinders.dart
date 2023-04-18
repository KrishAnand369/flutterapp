import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:oru_app/delivercylinders/deliver_mannually.dart';
import 'package:oru_app/functions.dart';
import 'package:oru_app/reusables.dart';
import 'package:oru_app/delivercylinders/delivery_scanner.dart';
import 'package:http/http.dart' as http;

class DeliverCylinders extends StatefulWidget {
  List qrList;

  String accessToken;

  DeliverCylinders(
      {Key? mykey, required this.qrList, required this.accessToken})
      : super(key: mykey);

  @override
  State<DeliverCylinders> createState() => _DeliverCylindersState();
}

class _DeliverCylindersState extends State<DeliverCylinders> {
  List cylinderId = [];
  bool flag = false;
  bool cancel = false;
  List customerID = [];
  List<String> customerName = [];
  Map<String, int> customerDetails = {};
  String dropDownvalueCustomer = "Select Customer";
  TextEditingController customerController = TextEditingController();

  @override
  void initState() {
    super.initState();

    fetchCustomerDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Deliver Cylinders',
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
          Card(
            elevation: 1,
            child: TypeAheadField(
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
          ),
          SizedBox(
            height: 60,
          ),
          IconButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => Delivery_Scanner(
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
              if (selectID() != null) {
                update();
                if (flag) {
                  toast("some QR codes are not valid");
                }
                flag = false;
                cylinderId.clear();
                if (widget.qrList.isEmpty) {
                  setState(() {
                    cancel = false;
                  });
                }
                _showConfirmationDialog();
              } else
               toast('Please Select a Customer') ;
            },
            child: const Text(
              "Submit",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
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
                      builder: (context) => DeliverMannually(
                            accessToken: widget.accessToken,
                          )),
                );
              },
              tileColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  selectID() {
    return customerDetails[dropDownvalueCustomer];
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

  void makePostRequestToDeliver(
      String accessToken, List cylinderId, int customersID) async {
    if (!cylinderId.isEmpty) {
      var url = Uri.parse('http://soc-erp.showcase.code7.in/api/deliver');

      var requestBody = jsonEncode({
        "customer": customersID,
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

  Future<void> _showConfirmationDialog() async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmation'),
          content: Text('Are you sure you want to submit?'),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                if (cancel) {
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        cylinderId.clear();
                        cancel = false;
                      });
                    },
                    child: Text("Cancel"),
                    style: ButtonStyle(),
                  );
                } else
                  Text("");
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: const Text('Proceed'),
              onPressed: () {
                // TODO: handle form submission
                update();
                if (flag) {
                  toast("some QR codes are not valid");
                }
                  makePostRequestToDeliver(
                      widget.accessToken, cylinderId, selectID());

                flag = false;
                cylinderId.clear();
                if (widget.qrList.isEmpty) {
                  setState(() {
                    cancel = false;
                  });
                }

                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('submitted successfully'),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
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
        customerDetails[i['name']] = i['id'];
      }
    } else {
      // Handle error
      toast('error in customerID');
    }
  }
}
