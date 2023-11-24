import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:usb_serial/usb_serial.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int x = 0;
  final limitCount = 10;
  final plotData = <FlSpot>[];
  String received = "";

  void updateGraph(String value) {
    while (plotData.length > limitCount) {
      plotData.removeAt(0);
    }
    setState(() {
      plotData.add(FlSpot(x.toDouble(), double.parse(value)));
      x += 500; // 500ms
    });
  }

  void checkUSB() async {
    List<UsbDevice> devices = await UsbSerial.listDevices();
    if (devices.isEmpty) return;

    UsbPort? port = await devices.first.create();
    port?.setPortParameters(115200, UsbPort.DATABITS_8, UsbPort.STOPBITS_1, UsbPort.PARITY_NONE);
    await port?.open();

    port?.inputStream?.listen((Uint8List data) {
      received = utf8.decode(data).replaceFirst("\r\n", "");
      setState(() => updateGraph(received));
    });
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 5,
      angle: 4.71239,
      child: Text("${value.toInt() / 1000}"),
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
                      minX: plotData.isNotEmpty ? plotData.first.x : 0,
                      maxX: plotData.isNotEmpty ? plotData.last.x : 0,
                      lineTouchData: const LineTouchData(enabled: false),
                      clipData: const FlClipData.all(),
                      lineBarsData: [LineChartBarData(spots: plotData)],
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
                          axisNameWidget: const Text('Time [sec]'),
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 35,
                            getTitlesWidget: bottomTitleWidgets,
                          ),
                        ),
                        leftTitles: AxisTitles(
                          axisNameSize: 20,
                          axisNameWidget: const Text('Voltage'),
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: 1,
                            reservedSize: 40,
                            getTitlesWidget: leftTitleWidgets,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Card(
                  margin: const EdgeInsets.only(top: 10),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                    child: Text("Serial Read: $received"),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
