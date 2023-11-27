import 'dart:async';
import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:usb_chart/chart_view.dart';
import 'package:usb_serial/usb_serial.dart';
import 'controller.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
  ]);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final Controller controller = Get.put(Controller());
  int xAxis = 0;
  final plotData = <FlSpot>[];
  int demoVal = 0;

  void updateGraph(double value) {
    plotData.add(FlSpot(xAxis.toDouble(), value));
    controller.updatePlot(plotData);
    xAxis += 2; // 2ms
  }

  void checkUSB() async {
    List<UsbDevice> devices = await UsbSerial.listDevices();
    if (devices.isEmpty) return;

    UsbPort? port = await devices.first.create();
    port?.setPortParameters(115200, UsbPort.DATABITS_8, UsbPort.STOPBITS_1, UsbPort.PARITY_NONE);
    await port?.open();

    port?.inputStream?.listen((Uint8List data) {
      String received = utf8.decode(data).replaceFirst("\r\n", "");
      updateGraph(double.parse(received));
    });
  }

  @override
  void initState() {
    checkUSB();

    // for testing
    Timer.periodic(const Duration(milliseconds: 2), (timer) {
      updateGraph(demoVal / 100);
      demoVal++;
      if (demoVal >= 500) demoVal = 0;
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text("Real Time USB Chart"),
        ),
        body: const Padding(
          padding: EdgeInsets.all(10),
          child: ChartView(),
        ),
      ),
    );
  }
}
