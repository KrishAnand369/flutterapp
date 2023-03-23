import 'dart:io';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class Scanner extends StatefulWidget {
  const Scanner({super.key});

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
                  Navigator.of(context).pop();
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

  void onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });

    controller.scannedDataStream
        .listen((barcode) => setState(() => this.barcode = barcode));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(backgroundColor: Colors.white,
          title: const Text('Scan Cylinders',style: TextStyle(color: Colors.black)),
          automaticallyImplyLeading: false,
          leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.arrow_back_rounded),
            color: Colors.black,
          ),
          actions:[IconButton(color: const Color.fromARGB(255, 236, 215, 19),
              icon: FutureBuilder<bool?>(
      future: controller?.getFlashStatus(),
      builder: (context, snapshot) {if (snapshot.data!=null)
      {return Icon(snapshot.data!? Icons.flash_on_rounded:Icons.flash_off_rounded);}
      else{return Container();}}
     ),
     onPressed: () async {
      await controller?.toggleFlash();
      setState(() {});
    },
  ),
IconButton(
  color: Colors.black,
              icon:FutureBuilder(
      future: controller?.getCameraInfo(),
      builder: (context, snapshot) {
        if (snapshot.data!=null){
          return const Icon(Icons.switch_camera_rounded);
          }
      else{
        return Container();}}
     
    ) ,
              onPressed: () async {
                await controller?.flipCamera();
                setState(() {});
              },
              
            )
] ,
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
                      Positioned(bottom: 10, child: buidResult()),
                      Positioned(bottom: 50, child: addButton())
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
