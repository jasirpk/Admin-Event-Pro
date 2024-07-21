// ignore_for_file: unnecessary_null_comparison

import 'package:admineventpro/bussiness_layer/entities/repos/snackbar.dart';
import 'package:admineventpro/data_layer/services/budget.dart';
import 'package:admineventpro/presentation/components/ui/custom_textfield.dart';
import 'package:flutter/material.dart';

class BottomSheetWidget extends StatelessWidget {
  const BottomSheetWidget({
    super.key,
    required this.eventTypeController,
    required this.dateController,
    required this.revenueController,
    required this.costController,
    required this.benefitController,
    required this.uid,
    required this.context,
  });

  final TextEditingController eventTypeController;
  final TextEditingController dateController;
  final TextEditingController revenueController;
  final TextEditingController costController;
  final TextEditingController benefitController;
  final String uid;
  final BuildContext context;

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
              controller: eventTypeController,
              keyboardtype: TextInputType.text,
              labelText: 'Event Type',
              prefixIcon: Icons.event,
            ),
            SizedBox(height: 10),
            CustomTextFieldWidget(
              controller: dateController,
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
                  dateController.text =
                      "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
                }
              },
            ),
            SizedBox(height: 10),
            CustomTextFieldWidget(
              controller: revenueController,
              readOnly: false,
              keyboardtype: TextInputType.number,
              labelText: 'Total Revenue',
              prefixIcon: Icons.currency_rupee,
            ),
            SizedBox(height: 10),
            CustomTextFieldWidget(
              controller: costController,
              readOnly: false,
              keyboardtype: TextInputType.number,
              labelText: 'Cost',
              prefixIcon: Icons.currency_rupee,
            ),
            SizedBox(height: 10),
            CustomTextFieldWidget(
              controller: benefitController,
              readOnly: false,
              keyboardtype: TextInputType.number,
              labelText: 'Benefit',
              prefixIcon: Icons.currency_rupee,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                if (eventTypeController.text.isNotEmpty &&
                    dateController.text.isNotEmpty &&
                    revenueController.text.isNotEmpty &&
                    costController.text.isNotEmpty &&
                    benefitController.text.isNotEmpty) {
                  if (uid != null) {
                    await BudgetTrack().addRevenue(
                        uid: uid,
                        eveneType: eventTypeController.text,
                        date: dateController.text,
                        revenue: revenueController.text,
                        cost: costController.text,
                        benefit: benefitController.text);
                    showCustomSnackBar('Success', 'Revenue added');
                    eventTypeController.clear();
                    dateController.clear();
                    revenueController.clear();
                    costController.clear();
                    benefitController.clear();
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
