import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:usb_serial/usb_serial.dart';

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
  int startIndex = 0;
  int xAxis = 0;
  int windowSize = 100;
  final plotData = <FlSpot>[];
  final plotToShow = <FlSpot>[];
  String received = "";

  void updateUI() {
    if (plotData.length <= windowSize) return;
    plotToShow.clear();
    plotToShow.addAll(plotData.getRange(startIndex, startIndex + windowSize));
    startIndex++;
    // clear some data from main list
    if (startIndex > windowSize) {
      plotData.removeRange(0, windowSize);
      startIndex = 0;
    }
    setState(() {});
  }

  void updateGraph(double value) {
    plotData.add(FlSpot(xAxis.toDouble(), value));
    xAxis += 2; // 2ms
  }

  void checkUSB() async {
    List<UsbDevice> devices = await UsbSerial.listDevices();
    if (devices.isEmpty) return;

    UsbPort? port = await devices.first.create();
    port?.setPortParameters(115200, UsbPort.DATABITS_8, UsbPort.STOPBITS_1, UsbPort.PARITY_NONE);
    await port?.open();

    port?.inputStream?.listen((Uint8List data) {
      received = utf8.decode(data).replaceFirst("\r\n", "");
      updateGraph(double.parse(received));
    });
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 5,
      angle: 4.71239,
      child: Text((value.toInt() / 1000).toStringAsFixed(1)),
    );
  }

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Text('${value}V'),
    );
  }

  @override
  void initState() {
    checkUSB();
    // for testing
    Timer.periodic(const Duration(milliseconds: 2), (timer) => updateGraph(Random().nextInt(500) / 100));
    // UI updater
    Timer.periodic(const Duration(milliseconds: 100), (timer) => updateUI());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text("Real Time USB Chart"),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                Expanded(
                  child: LineChart(
                    LineChartData(
                      minY: 0,
                      maxY: 5,
                      minX: plotToShow.isNotEmpty ? plotToShow.first.x : 0,
                      maxX: plotToShow.isNotEmpty ? plotToShow.last.x : 0,
                      lineBarsData: [LineChartBarData(spots: plotToShow, isCurved: true, dotData: const FlDotData(show: false))],
                      borderData: FlBorderData(
                        show: true,
                        border: const Border(left: BorderSide(), bottom: BorderSide()),
                      ),
                      titlesData: FlTitlesData(
                        show: true,
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        bottomTitles: AxisTitles(
                          axisNameWidget: const Text('Time[sec]'),
                          sideTitles: SideTitles(showTitles: true, reservedSize: 35, getTitlesWidget: bottomTitleWidgets),
                        ),
                        leftTitles: AxisTitles(
                          axisNameSize: 20,
                          axisNameWidget: const Text('Voltage'),
                          sideTitles: SideTitles(showTitles: true, reservedSize: 40, getTitlesWidget: leftTitleWidgets),
                        ),
                      ),
                    ),
                    duration: const Duration(milliseconds: 0),
                  ),
                ),
                Card(
                  margin: const EdgeInsets.only(top: 10),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                    child: Text("Serial Read: $received"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
