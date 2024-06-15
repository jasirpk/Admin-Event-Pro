import 'package:admineventpro/presentation/components/ui/silver_appbar.dart';
import 'package:admineventpro/presentation/components/ui/squre_container.dart';
import 'package:admineventpro/presentation/components/ui/view_all.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return CustomScrollView(
      slivers: [
        SilverAppBarWidget(key: UniqueKey(), screenHeight: screenHeight),
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
                ViewAllWidget(
                  text: 'View All',
                  screenHeight: screenHeight,
                  onpressed: () {},
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Container(
            height: 130,
            child: CarouselSlider.builder(
              itemCount: 30,
              itemBuilder: (context, index, pageIndex) {
                return Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.grey,
                  ),
                );
              },
              options: CarouselOptions(
                height: 200,
                aspectRatio: 16 / 9,
                reverse: false,
                viewportFraction: 0.35,
                autoPlayCurve: Curves.fastOutSlowIn,
                autoPlay: true,
                autoPlayInterval: Duration(seconds: 6),
                autoPlayAnimationDuration: Duration(seconds: 3),
                enlargeCenterPage: true,
                scrollDirection: Axis.horizontal,
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.only(top: 12, bottom: 14),
            child: SizedBox(
              height: 35,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 30,
                itemBuilder: (context, index) {
                  return Container(
                    margin: EdgeInsets.symmetric(
                        horizontal: 5), // Add margin between items
                    width: 100, // Fixed width for each item
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: Colors.grey, // Added color for visibility
                    ),
                    child: Center(
                      child: Text('hello',
                          style: TextStyle(
                              color: Colors
                                  .white)), // Center the text and add style
                    ),
                  );
                },
              ),
            ),
          ),
        ),
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
              padding: const EdgeInsets.only(bottom: 14),
              child: Container(
                height: screenHeight * 0.32,
                width: screenWidth * 0.90,
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.white60, width: 1),
                    borderRadius: BorderRadius.circular(10),
                    image: DecorationImage(
                        image: AssetImage('assets/images/cover_img_1.png'),
                        fit: BoxFit.cover,
                        colorFilter: ColorFilter.mode(
                            Colors.black.withOpacity(0.3), BlendMode.darken)),
                    color: Colors.grey),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        SqureContainerWidget(
                          screenHeight: screenHeight,
                          screenWidth: screenWidth,
                          image: 'assets/images/vendor_card_img.png',
                          text: 'Vendors',
                        ),
                        SqureContainerWidget(
                            screenHeight: screenHeight,
                            screenWidth: screenWidth,
                            image: 'assets/images/budget_card_img.png',
                            text: 'Budget')
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        SqureContainerWidget(
                            screenHeight: screenHeight,
                            screenWidth: screenWidth,
                            image: 'assets/images/checkList_card_img.png',
                            text: 'Checklist'),
                        SqureContainerWidget(
                            screenHeight: screenHeight,
                            screenWidth: screenWidth,
                            image: 'assets/images/message_card_img.png',
                            text: 'Messages')
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ViewAllWidget(
                screenHeight: screenHeight,
                onpressed: () {},
                text: 'Select a Template',
              ),
            ],
          ),
        )
      ],
    );
  }
}
