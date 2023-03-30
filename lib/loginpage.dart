import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:oru_app/functions.dart';
import 'package:oru_app/homepage.dart';
import 'package:oru_app/reusables.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Login", style: TextStyle(color: Colors.black)),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(10, 200, 10, 0),
          child: Column(
            children: [
              reusableTextField(
                "Email",
                Icons.person,
                false,
                email,
              ),
              const SizedBox(
                height: 30,
              ),
              reusableTextField(
                "Password",
                Icons.lock_outline,
                true,
                password,
              ),
              const SizedBox(
                height: 30,
              ),
              signInSignUpButton("Login", context, () {
                postRequest();
              }),
            ],
          ),
        ));
  }

  Future<void> postRequest() async {
    final url = Uri.parse('http://soc-erp.showcase.code7.in/api/authenticate');
    final headers = {'Content-Type': 'application/json'};
    final body = {
      'email': email.text.toString(),
      'password': password.text.toString()
    };
    final jsonBody = json.encode(body);
    try {
      final response = await http.post(url, headers: headers, body: jsonBody);

      if (response.statusCode == 200) {
        toast("Logined Successfully");

        // request successful, handle response data
        final responseData = json.decode(response.body);
        print(responseData['message']);
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => HomePage(
                      access_token: responseData["token"],
                    )));
        // ...
      } else if (response.statusCode == 400) {
        toast("Username and Password doesn't match");
        print('Request failed with status: ${response.statusCode}.');
      } else {
        toast("Enter valid email id");
      }
    } catch (e) {
      toast("Check internet connectivity");
    }
  }
}
