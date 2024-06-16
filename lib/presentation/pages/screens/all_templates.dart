import 'package:admineventpro/common/style.dart';
import 'package:admineventpro/logic/services/custom_appbar.dart';
import 'package:admineventpro/presentation/components/ui/silver_listview.dart';
import 'package:admineventpro/presentation/components/ui/custom_text.dart';
import 'package:admineventpro/presentation/pages/screens/listof_templates.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
              screenHeight: screenHeight, onpressed: () {}, text: 'Close'),
          sizedboxWidth
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SilverListViewWidget(
            screenHeight: screenHeight,
            screenWidth: screenWidth,
            text: 'Venues',
            image: 'assets/images/coktail_category.jpg',
            subImage: 'assets/images/venue_decoration_img.jpg',
            subText: 'Hello',
            opressed: () {
              Get.to(() => ListofTemplatesScreen());
            },
          ),
          SilverListViewWidget(
            screenHeight: screenHeight,
            screenWidth: screenWidth,
            text: 'Venues',
            image: 'assets/images/coktail_category.jpg',
            subImage: 'assets/images/venue_decoration_img.jpg',
            subText: 'Hello',
            opressed: () {},
          ),
          SilverListViewWidget(
            screenHeight: screenHeight,
            screenWidth: screenWidth,
            text: 'Venues',
            image: 'assets/images/coktail_category.jpg',
            subImage: 'assets/images/venue_decoration_img.jpg',
            subText: 'Helloghsdffhdfbddfbdffdsf',
            opressed: () {},
          ),
        ],
      ),
    );
  }
}
