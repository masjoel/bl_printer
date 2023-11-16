import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:wise_bluetooth_print/classes/paired_device.dart';
import 'package:wise_bluetooth_print/wise_bluetooth_print.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late List<PairedDevice> _devices;

  @override
  void initState() {
    super.initState();
    _devices = <PairedDevice>[];
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    List<PairedDevice> devices = <PairedDevice>[];

    try {
      devices = await WiseBluetoothPrint.getPairedDevices();
    } on PlatformException {
      devices = <PairedDevice>[];
    }

    if (!mounted) return;

    setState(() {
      _devices = devices;
    });
  }

  void initPrint(BuildContext context, String deviceUUID) {
    // You can add more language options other than ZPL and BZPL/ZPL II for printers
    // that don't support them.
    String orderDetails = '''
  Nama Barang        Qty    Harga
  Ini berisi deskripsi Nama Bara
  123456789012345678901234567890
  ------------------------------
  Barang A        2    100.000
  Barang B        1     75.000
  Barang C        3     50.000
  ------------------------------
  Total           6    325.000
  ''';

    String printTest = "     Nota Order Barang\n"
        "$orderDetails";
    // String printTextZPL = "^XA"
    //     "^LH55,30"
    //     "^FO20,10^CFD,27,13^FDNota Order Barang^FS"
    //     "^FO20,60^AD^FD$orderDetails^FS"
    //     "^FO40,160^BY2,2.0^BCN,100,Y,N,N,N^FD<PART,-1>^FS"
    //     "^XZ";

    // String printTextBZPL = "^XA"
    //     "^FO50,50^ADN,18,10,^FDCompany Name^FS"
    //     "^FO50,80^ADN,18,10,^FDCompany Address^FS"
    //     "^FO50,135^ADN,18,10,^FDExample text^FS"
    //     "^FO50,165^ADN,18,10,^FDMore example text^FS"
    //     "^FO50,165^ADN,18,10,^FDNota Order Barang^FS"
    //     "^FO50,165^ADN,18,10,^FD$orderDetails^FS"
    //     "^FO50,220^ADN,18,10,^FD2022-09-01T16:36:35Z^FS"
    //     "^XZ";

    showDialog(
      context: context,
      builder: (builder) => AlertDialog(
        // title: const Text(""),
        // content: const Text(""),
        actions: [
          // TextButton(
          //   onPressed: () async {
          //     await WiseBluetoothPrint.print(deviceUUID, printTextZPL);
          //     // ignore: use_build_context_synchronously
          //     Navigator.of(context).pop();
          //   },
          //   child: const Text("ZPL"),
          // ),
          // TextButton(
          //   onPressed: () async {
          //     await WiseBluetoothPrint.print(deviceUUID, printTextBZPL);
          //     // ignore: use_build_context_synchronously
          //     Navigator.of(context).pop();
          //   },
          //   child: const Text("B-ZPL/ZPL II"),
          // ),
          TextButton(
            onPressed: () async {
              await WiseBluetoothPrint.print(deviceUUID, printTest);
              // ignore: use_build_context_synchronously
              Navigator.of(context).pop();
            },
            child: const Text("Cetak Nota"),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Close", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
      appBar: AppBar(
        title: const Text("Wise Bluetooth Print"),
      ),
      body: Padding(
          padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
          child: ListView.builder(
              shrinkWrap: true,
              itemCount: _devices.length,
              itemBuilder: (context, index) {
                if (_devices[index].name.contains("RPP")) {
                  return GestureDetector(
                    onTap: () => initPrint(context, _devices[index].socketId),
                    child: Card(
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ListTile(
                            title: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(_devices[index].name),
                                  Text(_devices[index].hardwareAddress)
                                ]),
                            // subtitle: Text(_devices[index].socketId),
                          )
                        ],
                      ),
                    ),
                  );
                } else {
                  return Container();
                }
              })),
    ));
  }

}
