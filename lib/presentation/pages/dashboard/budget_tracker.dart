import 'package:admineventpro/common/assigns.dart';
import 'package:admineventpro/common/style.dart';
import 'package:admineventpro/data_layer/services/budget.dart';
import 'package:admineventpro/presentation/components/budget/bottomsheet.dart';
import 'package:admineventpro/presentation/components/budget/event_list.dart';
import 'package:admineventpro/presentation/components/budget/piechart.dart';
import 'package:admineventpro/presentation/components/event_detail/custom_headline.dart';
import 'package:admineventpro/presentation/components/shimmer/shimmer_with_sublist.dart';
import 'package:admineventpro/presentation/components/budget/revenue_detail.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BudgetTracker extends StatefulWidget {
  BudgetTracker({super.key});

  @override
  State<BudgetTracker> createState() => _BudgetTrackerState();
}

class _BudgetTrackerState extends State<BudgetTracker> {
  final TextEditingController eventTypeController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController revenueController = TextEditingController();
  final TextEditingController costController = TextEditingController();
  final TextEditingController benefitController = TextEditingController();
  final uid = FirebaseAuth.instance.currentUser!.uid;

  double totalBudget = 0;
  double totalBudgetCost = 0;
  double totalBudgetBenefit = 0;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  void fetchData() async {
    BudgetTrack budgetTrack = BudgetTrack();
    QuerySnapshot snapshot = await budgetTrack.getBudgetReveneu(uid).first;

    double totalSum = 0;
    double totalCost = 0;
    double totalBenefit = 0;

    var documents = snapshot.docs;
    for (var document in documents) {
      var data = document.data() as Map<String, dynamic>;

      if (data['totalRevenue'] is String &&
          data['benefit'] is String &&
          data['cost'] is String) {
        List<String> totalRevenue = data['totalRevenue'].split(',');
        List<String> totalCostList = data['cost'].split(',');
        List<String> totalBenefitList = data['benefit'].split(',');

        for (var revenueStr in totalRevenue) {
          int revenue = int.parse(revenueStr.trim());
          totalSum += revenue;
        }
        for (var costStr in totalCostList) {
          int cost = int.parse(costStr.trim());
          totalCost += cost;
        }
        for (var benefitStr in totalBenefitList) {
          int benefit = int.parse(benefitStr.trim());
          totalBenefit += benefit;
        }
      }
    }

    setState(() {
      totalBudget = totalSum;
      totalBudgetBenefit = totalBenefit;
      totalBudgetCost = totalCost;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    BudgetTrack budgetTrack = BudgetTrack();

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showModalBottomSheet(
            backgroundColor: Colors.black,
            context: context,
            isScrollControlled: true,
            builder: (context) => BottomSheetWidget(
                eventTypeController: eventTypeController,
                dateController: dateController,
                revenueController: revenueController,
                costController: costController,
                benefitController: benefitController,
                uid: uid,
                context: context),
          );
        },
        label: Text('+ Track'),
      ),
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          Assigns.trackRevenue,
          style: TextStyle(
            fontFamily: 'JacquesFracois',
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        actions: [
          Icon(Icons.paid, color: Colors.white, size: 30),
          sizedboxWidth,
        ],
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: Icon(
            CupertinoIcons.back,
            color: Colors.white,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PieChartWidget(
                  screenHeight: screenHeight,
                  totalBudget: totalBudget,
                  totalBudgetCost: totalBudgetCost,
                  totalBudgetBenefit: totalBudgetBenefit),
              Column(
                children: [
                  RevenueDetailWidget(
                    text: 'Total Revenue',
                    backgroundColor: Colors.blue,
                    budgetTrack: totalBudget,
                  ),
                  RevenueDetailWidget(
                    text: 'Cost',
                    backgroundColor: Colors.red,
                    budgetTrack: totalBudgetCost,
                  ),
                  RevenueDetailWidget(
                    text: 'Benefit',
                    backgroundColor: Colors.green,
                    budgetTrack: totalBudgetBenefit,
                  ),
                ],
              ),
              sizedbox,
              CustomHeadLineTextWidget(
                screenHeight: MediaQuery.of(context).size.height,
                text: 'History',
              ),
              sizedbox,
              StreamBuilder<QuerySnapshot>(
                stream: budgetTrack.getBudgetReveneu(uid),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return ShimmerAllSubcategories(
                      screenHeight: screenHeight,
                      screenWidth: screenWidth,
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Text(
                        'No Templates Found for $uid',
                        style: TextStyle(color: Colors.white),
                      ),
                    );
                  }
                  var documents = snapshot.data!.docs;

                  return BudgetHistoryWidget(
                    documents: documents,
                    budgetTrack: budgetTrack,
                    uid: uid,
                    screenHeight: screenHeight,
                    screenWidth: screenWidth,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
