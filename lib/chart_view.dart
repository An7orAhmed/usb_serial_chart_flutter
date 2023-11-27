import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'controller.dart';

class ChartView extends StatelessWidget {
  const ChartView({super.key});

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
  Widget build(BuildContext context) {
    final Controller controller = Get.put(Controller());
    return Obx(
      () => LineChart(
        LineChartData(
          minY: 0,
          maxY: 5,
          minX: controller.plotToShow.isNotEmpty ? controller.plotToShow.first.x : 0,
          maxX: controller.plotToShow.isNotEmpty ? controller.plotToShow.last.x : 0,
          lineBarsData: [LineChartBarData(spots: controller.plotToShow, isCurved: true, dotData: const FlDotData(show: false))],
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
    );
  }
}
