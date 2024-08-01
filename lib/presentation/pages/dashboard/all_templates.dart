import 'package:admineventpro/common/style.dart';
import 'package:admineventpro/presentation/components/ui/custom_appbar.dart';
import 'package:admineventpro/presentation/components/ui/silver_listview.dart';
import 'package:admineventpro/presentation/components/ui/custom_text.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class AllTemplatesScreen extends StatelessWidget {
  const AllTemplatesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: CustomAppBarWithDivider(
        title: 'Templates',
        actions: [
          CustomText(
              screenHeight: screenHeight,
              onpressed: () {
                Get.back();
              },
              text: 'Close'),
          sizedboxWidth
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: screenHeight,
              ),
              child: SilverListViewWidget(
                screenHeight: screenHeight,
                screenWidth: screenWidth,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
