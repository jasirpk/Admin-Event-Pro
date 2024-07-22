import 'package:admineventpro/common/assigns.dart';
import 'package:admineventpro/common/style.dart';
import 'package:admineventpro/data_layer/services/budget.dart';
import 'package:admineventpro/presentation/components/budget/bottomsheet.dart';
import 'package:admineventpro/presentation/components/budget/revenues.dart';
import 'package:admineventpro/presentation/components/shimmer/shimmer_with_sublist.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class BudgetHistoryWidget extends StatelessWidget {
  BudgetHistoryWidget({
    super.key,
    required this.documents,
    required this.budgetTrack,
    required this.uid,
    required this.screenHeight,
    required this.screenWidth,
  });

  final List<QueryDocumentSnapshot<Object?>> documents;
  final BudgetTrack budgetTrack;
  final String uid;
  final double screenHeight;
  final double screenWidth;
  final TextEditingController eventTypeController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController revenueController = TextEditingController();
  final TextEditingController costController = TextEditingController();
  final TextEditingController benefitController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: documents.length,
      reverse: true,
      itemBuilder: (context, index) {
        var document = documents[index];
        String budgetId = document.id;
        var data = document.data() as Map<String, dynamic>;

        return FutureBuilder<DocumentSnapshot?>(
          future: budgetTrack.getBudgetRevenueById(uid, budgetId),
          builder: (context, revenueSanpshot) {
            if (revenueSanpshot.connectionState == ConnectionState.waiting) {
              return ShimmerAllSubcategories(
                screenHeight: screenHeight,
                screenWidth: screenWidth,
              );
            }

            if (!revenueSanpshot.hasData ||
                revenueSanpshot.data == null ||
                revenueSanpshot.data!.data() == null) {
              return Center(
                child: Text(
                  'Details not found for $budgetId',
                  style: TextStyle(color: Colors.white),
                ),
              );
            }
            return Container(
              margin: EdgeInsets.symmetric(vertical: 8),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        data['eventType'],
                        style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: screenHeight * 0.020),
                      ),
                      Text(
                        data['date'],
                        style: TextStyle(color: myColor),
                      )
                    ],
                  ),
                  sizedboxWidth,
                  RevenuesWidget(
                    data: data,
                    text: Assigns.totalRevenue,
                    value: data['totalRevenue'],
                  ),
                  RevenuesWidget(
                    data: data,
                    text: Assigns.Benefit,
                    value: data['benefit'],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      RevenuesWidget(
                        data: data,
                        text: Assigns.cost,
                        value: data['cost'],
                      ),
                      InkWell(
                        onTap: () {
                          showModalBottomSheet(
                            backgroundColor: Colors.black,
                            context: context,
                            isScrollControlled: true,
                            builder: (context) => BottomSheetWidget(
                              isService: false,
                              eventTypeController: eventTypeController,
                              dateController: dateController,
                              revenueController: revenueController,
                              benefitController: benefitController,
                              costController: costController,
                              uid: uid,
                              context: context,
                              revenueType: data['eventType'],
                              date: data['date'],
                              revenue: data['totalRevenue'],
                              cost: data['benefit'],
                              benefit: data['cost'],
                              budgetId: budgetId,
                            ),
                          );
                        },
                        child: Icon(
                          Icons.edit,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
