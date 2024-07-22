// ignore_for_file: unnecessary_null_comparison

import 'package:admineventpro/bussiness_layer/entities/repos/snackbar.dart';
import 'package:admineventpro/data_layer/services/budget.dart';
import 'package:admineventpro/presentation/components/ui/custom_textfield.dart';
import 'package:flutter/material.dart';

class BottomSheetWidget extends StatefulWidget {
  const BottomSheetWidget({
    super.key,
    this.revenueType,
    this.date,
    this.revenue,
    this.benefit,
    this.cost,
    required this.eventTypeController,
    required this.dateController,
    required this.revenueController,
    required this.costController,
    required this.benefitController,
    required this.uid,
    required this.context,
    required this.isService,
    this.budgetId,
  });

  final TextEditingController eventTypeController;
  final TextEditingController dateController;
  final TextEditingController revenueController;
  final TextEditingController costController;
  final TextEditingController benefitController;
  final bool isService;
  final String uid;
  final BuildContext context;
  final String? revenueType;
  final String? date;
  final String? revenue;
  final String? benefit;
  final String? cost;
  final String? budgetId;

  @override
  State<BottomSheetWidget> createState() => _BottomSheetWidgetState();
}

class _BottomSheetWidgetState extends State<BottomSheetWidget> {
  @override
  void initState() {
    widget.eventTypeController.text = widget.revenueType ?? '';
    widget.dateController.text = widget.date ?? '';
    widget.revenueController.text = widget.revenue ?? '';
    widget.benefitController.text = widget.benefit ?? '';
    widget.costController.text = widget.cost ?? '';
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomTextFieldWidget(
              readOnly: false,
              controller: widget.eventTypeController,
              keyboardtype: TextInputType.text,
              labelText: 'Event Type',
              prefixIcon: Icons.event,
            ),
            SizedBox(height: 10),
            CustomTextFieldWidget(
              controller: widget.dateController,
              keyboardtype: TextInputType.datetime,
              labelText: 'Date',
              prefixIcon: Icons.calendar_month,
              readOnly: true,
              onTap: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2101),
                );
                if (pickedDate != null) {
                  widget.dateController.text =
                      "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
                }
              },
            ),
            SizedBox(height: 10),
            CustomTextFieldWidget(
              controller: widget.revenueController,
              readOnly: false,
              keyboardtype: TextInputType.number,
              labelText: 'Total Revenue',
              prefixIcon: Icons.currency_rupee,
            ),
            SizedBox(height: 10),
            CustomTextFieldWidget(
              controller: widget.costController,
              readOnly: false,
              keyboardtype: TextInputType.number,
              labelText: 'Cost',
              prefixIcon: Icons.currency_rupee,
            ),
            SizedBox(height: 10),
            CustomTextFieldWidget(
              controller: widget.benefitController,
              readOnly: false,
              keyboardtype: TextInputType.number,
              labelText: 'Benefit',
              prefixIcon: Icons.currency_rupee,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                if (widget.eventTypeController.text.isNotEmpty &&
                    widget.dateController.text.isNotEmpty &&
                    widget.revenueController.text.isNotEmpty &&
                    widget.costController.text.isNotEmpty &&
                    widget.benefitController.text.isNotEmpty) {
                  if (widget.uid != null && widget.isService) {
                    await BudgetTrack().addRevenue(
                        uid: widget.uid,
                        eveneType: widget.eventTypeController.text,
                        date: widget.dateController.text,
                        revenue: widget.revenueController.text,
                        cost: widget.costController.text,
                        benefit: widget.benefitController.text);
                    showCustomSnackBar('Success', 'Revenue added');
                    widget.eventTypeController.clear();
                    widget.dateController.clear();
                    widget.revenueController.clear();
                    widget.costController.clear();
                    widget.benefitController.clear();
                  } else {
                    Text('User Not logged In');
                  }
                  if (widget.uid != null && !widget.isService) {
                    await BudgetTrack().updateRevenue(
                        uid: widget.uid,
                        eventType: widget.eventTypeController.text,
                        date: widget.dateController.text,
                        revenue: widget.revenueController.text,
                        cost: widget.costController.text,
                        benefit: widget.benefitController.text,
                        budgetId: widget.budgetId ?? '');
                    showCustomSnackBar('Success',
                        widget.isService ? 'Revenue added' : 'Revenue Updated');
                    widget.eventTypeController.clear();
                    widget.dateController.clear();
                    widget.revenueController.clear();
                    widget.costController.clear();
                    widget.benefitController.clear();
                  } else {
                    Text('User Not logged In');
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      backgroundColor: Colors.red,
                      content: Text('Please fill all the required fields')));
                }
              },
              child: Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
