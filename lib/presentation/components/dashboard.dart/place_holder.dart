import 'package:admineventpro/common/assigns.dart';
import 'package:admineventpro/common/style.dart';
import 'package:admineventpro/data_layer/services/category.dart';
import 'package:admineventpro/presentation/components/dashboard.dart/vendor.dart';
import 'package:admineventpro/presentation/pages/dashboard/budget_tracker.dart';
import 'package:admineventpro/presentation/pages/dashboard/checklist.dart';
import 'package:admineventpro/presentation/components/dashboard.dart/listview.dart';
import 'package:admineventpro/presentation/components/dashboard.dart/listview_name.dart';
import 'package:admineventpro/presentation/components/ui/silver_appbar.dart';
import 'package:admineventpro/presentation/components/ui/squre_container.dart';
import 'package:admineventpro/presentation/components/ui/custom_text.dart';
import 'package:admineventpro/presentation/pages/dashboard/all_templates.dart';
import 'package:admineventpro/presentation/pages/dashboard/message_list.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PlaceHolderWidget extends StatelessWidget {
  const PlaceHolderWidget({
    super.key,
    required this.screenHeight,
    required this.databaseMethods,
    required this.screenWidth,
  });

  final double screenHeight;
  final DatabaseMethods databaseMethods;
  final double screenWidth;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: NeverScrollableScrollPhysics(),
      slivers: [
        SilverAppBarWidget(
          key: UniqueKey(),
          screenHeight: screenHeight,
          coveImage: Assigns.image3,
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.only(left: 8, top: 12, bottom: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Popular Categories',
                  style: TextStyle(
                    fontSize: screenHeight * 0.020,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                    fontFamily: 'JacquesFracois',
                  ),
                ),
                CustomText(
                  text: 'View All',
                  screenHeight: screenHeight,
                  onpressed: () {
                    Get.to(() => AllTemplatesScreen(),
                        transition: Transition.fade,
                        duration: Duration(seconds: 1));
                  },
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: ListViewWidget(
            databaseMethods: databaseMethods,
            selectedValue: Assigns.selectedValue,
            screenHeight: screenHeight,
            screenWidth: screenWidth,
          ),
        ),
        ListViewName(
            databaseMethods: databaseMethods,
            selectedValue: Assigns.selectedValue),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Divider(
              thickness: 1.5,
              indent: 26,
              endIndent: 28,
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Center(
            child: Padding(
              padding: EdgeInsets.only(bottom: 14),
              child: Container(
                height: screenHeight * 0.32,
                width: screenWidth * 0.90,
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.white60, width: 1),
                    borderRadius: BorderRadius.circular(10),
                    image: DecorationImage(
                      image: AssetImage(Assigns.image3),
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(
                          Colors.black.withOpacity(0.3), BlendMode.darken),
                    )),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        InkWell(
                          onTap: () {
                            Get.to(() => ReceiptPage(),
                                transition: Transition.fade,
                                duration: Duration(milliseconds: 800));
                          },
                          child: SqureContainerWidget(
                            screenHeight: screenHeight,
                            screenWidth: screenWidth,
                            image: 'assets/images/vendor_card_img.png',
                            text: 'Vendors',
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            Get.to(() => BudgetTracker(),
                                transition: Transition.fade,
                                duration: Duration(milliseconds: 800));
                          },
                          child: SqureContainerWidget(
                            screenHeight: screenHeight,
                            screenWidth: screenWidth,
                            image: 'assets/images/budget_card_img.png',
                            text: 'Budget',
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        InkWell(
                          onTap: () {
                            Get.to(() => ChecklistScreen(),
                                transition: Transition.fade,
                                duration: Duration(milliseconds: 800));
                          },
                          child: SqureContainerWidget(
                            screenHeight: screenHeight,
                            screenWidth: screenWidth,
                            image: 'assets/images/checkList_card_img.png',
                            text: 'Checklist',
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            Get.to(() => MessageListScreen(),
                                transition: Transition.fade,
                                duration: Duration(milliseconds: 800));
                          },
                          child: SqureContainerWidget(
                            screenHeight: screenHeight,
                            screenWidth: screenWidth,
                            image: 'assets/images/message_card_img.png',
                            text: 'Messages',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: sizedbox,
        ),
        SliverToBoxAdapter(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              CustomText(
                screenHeight: screenHeight,
                onpressed: () {
                  Get.to(() => AllTemplatesScreen(),
                      transition: Transition.fade,
                      duration: Duration(seconds: 1));
                },
                text: 'Select a Template',
              ),
            ],
          ),
        ),
      ],
    );
  }
}
