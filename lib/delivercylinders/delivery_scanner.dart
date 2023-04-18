import 'dart:io';
import 'package:flutter/material.dart';
import 'package:oru_app/functions.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:oru_app/delivercylinders/delivercylinders.dart';
import 'package:flutter_beep/flutter_beep.dart';

class Delivery_Scanner extends StatefulWidget {
  List qrList;
  String accessToken;
  Delivery_Scanner(
      {Key? mykey, required this.qrList, required this.accessToken})
      : super(key: mykey);

  @override
  State<Delivery_Scanner> createState() => _Delivery_ScannerState();
}

class _Delivery_ScannerState extends State<Delivery_Scanner> {
  final qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? barcode;

  QRViewController? controller;
  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Future<void> reassemble() async {
    super.reassemble();

    if (Platform.isAndroid) {
      await controller!.pauseCamera();
    }
    controller!.resumeCamera();
  }

  Widget buidResult() => Container(
      padding: const EdgeInsets.all(15),
      decoration: const BoxDecoration(color: Colors.lightGreen),
      child: Text(
        barcode != null ? 'RESULT :${barcode!.code}' : 'Scan a QR Code',
        maxLines: 3,
      ));

  Widget addButton() => Container(
        padding: const EdgeInsets.all(10),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ElevatedButton(
                onPressed: () {
                  try {
                    setState(() {
                      if (widget.qrList
                          .contains('${barcode!.code}'.substring(4))) {
                        toast('${barcode!.code}' + " is already added");
                      } else if (!widget.qrList
                              .contains('${barcode!.code}'.substring(4)) &&
                          {barcode!.code} != null) {
                        widget.qrList.add('${barcode!.code}'.substring(4));
                        toast("added " + '${barcode!.code}');
                      }
                    });
                  } catch (e) {}
                },
                child: const Text('add'))
          ],
        ),
      );

  Widget buildQrView(BuildContext context) => QRView(
        key: qrKey,
        onQRViewCreated: onQRViewCreated,
        overlay: QrScannerOverlayShape(
          borderRadius: 20,
          borderWidth: 15,
          borderColor: Colors.blue,
        ),
      );
  Barcode? lastScanned;

  void onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });

    controller.scannedDataStream.listen((barcode) {
      if (lastScanned?.code != barcode.code) {
        lastScanned = barcode;
        setState(() => this.barcode = barcode);
        FlutterBeep.playSysSound(41);
        Fluttertoast.showToast(
            msg: "Scanned: ${barcode.code}",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.black,
            textColor: Colors.white,
            fontSize: 16.0);
      }
    });
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
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Proceed'),
              onPressed: () {
                // TODO: handle form submission
                dispose();
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => DeliverCylinders(
                              qrList: widget.qrList,
                              accessToken: widget.accessToken,
                            )));

                //Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
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

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: const Text('Scan Cylinders',
              style: TextStyle(color: Colors.black)),
          automaticallyImplyLeading: false,
          leading: IconButton(
            onPressed: () {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => DeliverCylinders(
                            qrList: widget.qrList,
                            accessToken: widget.accessToken,
                          )));
            },
            icon: const Icon(Icons.arrow_back_rounded),
            color: Colors.black,
          ),
          actions: [
            IconButton(
              color: const Color.fromARGB(255, 236, 215, 19),
              icon: FutureBuilder<bool?>(
                  future: controller?.getFlashStatus(),
                  builder: (context, snapshot) {
                    if (snapshot.data != null) {
                      return Icon(snapshot.data!
                          ? Icons.flash_on_rounded
                          : Icons.flash_off_rounded);
                    } else {
                      return Container();
                    }
                  }),
              onPressed: () async {
                await controller?.toggleFlash();
                setState(() {});
              },
            ),
            IconButton(
              color: Colors.black,
              icon: FutureBuilder(
                  future: controller?.getCameraInfo(),
                  builder: (context, snapshot) {
                    if (snapshot.data != null) {
                      return const Icon(Icons.switch_camera_rounded);
                    } else {
                      return Container();
                    }
                  }),
              onPressed: () async {
                await controller?.flipCamera();
                setState(() {});
              },
            )
          ],
        ),
        body: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(0),
          child: Column(
            children: [
              Expanded(
                flex: 6,
                child: Scaffold(
                  body: Stack(
                    alignment: Alignment.center,
                    children: <Widget>[
                      buildQrView(context),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Scaffold(
                  body: Stack(
                    alignment: Alignment.center,
                    children: <Widget>[
                      Positioned(bottom: 90, child: buidResult()),
                      Positioned(bottom: 10, child: addButton()),
                    ],
                  ),
                ),
              ),
              Divider(),
              ElevatedButton(
                  onPressed: () {
                    _showConfirmationDialog();
                  },
                  child: Text("Submit")),
              SizedBox(
                height: 10,
              )
            ],
          ),
        ),
      ),
    );
  }
}
