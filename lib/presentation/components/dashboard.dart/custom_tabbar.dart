import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:admineventpro/common/style.dart';
import 'package:get/get.dart';

class CustomTabAppbar extends StatelessWidget implements PreferredSizeWidget {
  const CustomTabAppbar({
    Key? key,
    this.dividerThickness = 1.5,
    required this.screenHeight,
  }) : super(key: key);

  final double screenHeight;
  final double dividerThickness;

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize: Size.fromHeight(kToolbarHeight + 40),
      child: AppBar(
        leading: InkWell(
          onTap: () {
            Get.back();
          },
          child: Icon(
            CupertinoIcons.back,
            color: Colors.white,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.black,
        title: Text(
          "All",
          style: TextStyle(
            color: Colors.white,
            fontSize: screenHeight * 0.016,
          ),
        ),
        actions: [
          Icon(
            Icons.search,
            color: Colors.white,
          ),
          SizedBox(
            width: 20,
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Container(
              color: myColor,
              height: 27,
              width: 27,
            ),
          ),
          SizedBox(
            width: 20,
          ),
        ],
        bottom: TabBar(
          dividerColor: Colors.black,
          indicatorSize: TabBarIndicatorSize.tab,
          indicator: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            color: myColor,
          ),
          unselectedLabelColor: Colors.white,
          labelStyle: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: screenHeight * 0.016,
          ),
          tabs: [
            Tab(
              text: "Available Templates",
            ),
            Tab(
              text: "Generated Templates",
            )
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight + 40);
}
