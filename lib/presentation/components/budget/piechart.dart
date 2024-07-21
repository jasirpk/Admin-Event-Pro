import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class PieChartWidget extends StatelessWidget {
  const PieChartWidget({
    super.key,
    required this.screenHeight,
    required this.totalBudget,
    required this.totalBudgetCost,
    required this.totalBudgetBenefit,
  });

  final double screenHeight;
  final double totalBudget;
  final double totalBudgetCost;
  final double totalBudgetBenefit;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: screenHeight * 0.4,
      child: PieChart(
        PieChartData(
          sections: [
            PieChartSectionData(
              value:
                  totalBudget > 0 ? (totalBudgetCost / totalBudget) * 100 : 0,
              color: Colors.red,
              title:
                  '${totalBudget > 0 ? ((totalBudgetCost / totalBudget) * 100).toStringAsFixed(1) : 0}%',
              radius: 50,
              titleStyle: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            PieChartSectionData(
              value: totalBudget > 0
                  ? (totalBudgetBenefit / totalBudget) * 100
                  : 0,
              color: Colors.green,
              title:
                  '${totalBudget > 0 ? ((totalBudgetBenefit / totalBudget) * 100).toStringAsFixed(1) : 0}%',
              radius: 50,
              titleStyle: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            PieChartSectionData(
              value: totalBudget > 0
                  ? ((totalBudget - totalBudgetCost - totalBudgetBenefit) /
                          totalBudget) *
                      100
                  : 0,
              color: Colors.blue,
              title:
                  '${totalBudget > 0 ? (((totalBudget - totalBudgetCost - totalBudgetBenefit) / totalBudget) * 100).toStringAsFixed(1) : 0}%',
              radius: 50,
              titleStyle: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
          sectionsSpace: 2,
          centerSpaceRadius: 70,
        ),
      ),
    );
  }
}
