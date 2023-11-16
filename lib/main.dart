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

    String printTest = "Nota Order Barang\n"
        "$orderDetails";
    WiseBluetoothPrint.print(deviceUUID, printTest);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
      appBar: AppBar(
        title: const Text("Bluetooth Print"),
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
                      color: const Color.fromARGB(255, 245, 247, 249),
                      shadowColor: const Color.fromARGB(255, 11, 90, 186),
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ListTile(
                            title: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('Cetak Nota')
                                ]),
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
