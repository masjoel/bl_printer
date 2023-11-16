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
    WiseBluetoothPrint.print(deviceUUID, printTest);
    // showDialog(
    //   context: context,
    //   builder: (builder) => AlertDialog(
    //     actions: [
    //       ElevatedButton(
    //         onPressed: () async {
    //           await WiseBluetoothPrint.print(deviceUUID, printTest);
    //           // ignore: use_build_context_synchronously
    //           Navigator.of(context).pop();
    //         },
    //         child: const Text("Cetak Nota"),
    //       ),
    //       ElevatedButton(
    //         onPressed: () => Navigator.of(context).pop(),
    //         child: const Text("Batal", style: TextStyle(color: Colors.red)),
    //       ),
    //     ],
    //   ),
    // );
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
