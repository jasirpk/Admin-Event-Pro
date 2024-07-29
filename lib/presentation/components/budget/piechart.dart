import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class PieChartWidget extends StatefulWidget {
  const PieChartWidget({
    super.key,
    required this.screenHeight,
    required this.totalBudget,
    required this.totalBudgetCost,
    required this.totalBudgetBenefit,
    required this.refreshData,
  });

  final double screenHeight;
  final double totalBudget;
  final double totalBudgetCost;
  final double totalBudgetBenefit;
  final VoidCallback refreshData;

  @override
  State<PieChartWidget> createState() => _PieChartWidgetState();
}

class _PieChartWidgetState extends State<PieChartWidget> {
  @override
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.screenHeight * 0.4,
      child: Stack(
        alignment: Alignment.center,
        children: [
          PieChart(
            PieChartData(
              sections: [
                PieChartSectionData(
                  value: widget.totalBudget > 0
                      ? (widget.totalBudgetCost / widget.totalBudget) * 100
                      : 0,
                  color: Colors.red,
                  title:
                      '${widget.totalBudget > 0 ? ((widget.totalBudgetCost / widget.totalBudget) * 100).toStringAsFixed(1) : 0}%',
                  radius: 50,
                  titleStyle: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                PieChartSectionData(
                  value: widget.totalBudget > 0
                      ? (widget.totalBudgetBenefit / widget.totalBudget) * 100
                      : 0,
                  color: Colors.green,
                  title:
                      '${widget.totalBudget > 0 ? ((widget.totalBudgetBenefit / widget.totalBudget) * 100).toStringAsFixed(1) : 0}%',
                  radius: 50,
                  titleStyle: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                PieChartSectionData(
                  value: widget.totalBudget > 0
                      ? ((widget.totalBudget -
                                  widget.totalBudgetCost -
                                  widget.totalBudgetBenefit) /
                              widget.totalBudget) *
                          100
                      : 0,
                  color: Colors.blue,
                  title:
                      '${widget.totalBudget > 0 ? (((widget.totalBudget - widget.totalBudgetCost - widget.totalBudgetBenefit) / widget.totalBudget) * 100).toStringAsFixed(1) : 0}%',
                  radius: 50,
                  titleStyle: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
              sectionsSpace: 2,
              centerSpaceRadius: 70, // Ensure this is enough space for the icon
            ),
          ),
          Center(
            child: IconButton(
              onPressed: widget.refreshData,
              icon: Icon(
                Icons.refresh,
                color: Colors.white,
              ),
            ),
          )
        ],
      ),
    );
  }
}
