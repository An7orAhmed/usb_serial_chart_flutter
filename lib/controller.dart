import 'package:fl_chart/fl_chart.dart';
import 'package:get/get.dart';

class Controller extends GetxController {
  int startIndex = 0;
  int windowSize = 2000;
  final plotToShow = <FlSpot>[].obs;

  void updatePlot(List<FlSpot> plotData) {
    plotToShow.clear();
    if (plotData.length <= windowSize) {
      plotToShow.addAll(plotData);
      return;
    }
    if (startIndex > plotData.length - windowSize) return;
    plotToShow.addAll(plotData.getRange(startIndex, startIndex + windowSize));
    startIndex++;
    // clear some data from main list
    if (startIndex > windowSize) {
      plotData.removeRange(0, windowSize);
      startIndex = 0;
    }
  }
}
