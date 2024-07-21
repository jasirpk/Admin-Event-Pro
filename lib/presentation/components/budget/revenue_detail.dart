import 'package:admineventpro/common/style.dart';
import 'package:flutter/material.dart';

class RevenueDetailWidget extends StatelessWidget {
  final String text;
  final Color backgroundColor;
  final double budgetTrack;

  const RevenueDetailWidget(
      {super.key,
      required this.text,
      required this.backgroundColor,
      required this.budgetTrack});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: ListTile(
        leading: CircleAvatar(
          radius: 10,
          backgroundColor: backgroundColor,
        ),
        title: Text(
          text,
          textAlign: TextAlign.start,
          style: TextStyle(letterSpacing: 1, color: Colors.white),
        ),
        trailing: Text(
          "${budgetTrack.toStringAsFixed(2)} ₹",
          style: TextStyle(color: myColor, fontSize: 14),
        ),
      ),
    );
  }
}
