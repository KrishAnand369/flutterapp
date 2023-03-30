import 'dart:io';
import 'package:flutter/material.dart';
import 'package:oru_app/functions.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'fillcylinders.dart';
import 'package:flutter_beep/flutter_beep.dart';

class Scanner extends StatefulWidget {
  List qrList;
  String accessToken;
  Scanner({Key? mykey, required this.qrList, required this.accessToken})
      : super(key: mykey);

  @override
  State<Scanner> createState() => _ScannerState();
}

class _ScannerState extends State<Scanner> {
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
      padding: const EdgeInsets.all(10),
      decoration: const BoxDecoration(color: Colors.lightGreen),
      child: Text(
        barcode != null ? 'RESULT :${barcode!.code}' : 'Scan a QR fCode',
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

  /*void onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });

    controller.scannedDataStream
        .listen((barcode) => setState(() => this.barcode = barcode));
  }*/
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
                      builder: (context) => FillCylinders(
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
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => FillCylinders(
                                  qrList: widget.qrList,
                                  accessToken: widget.accessToken,
                                )));
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
