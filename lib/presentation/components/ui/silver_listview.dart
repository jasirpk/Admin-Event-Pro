import 'dart:ui';

import 'package:admineventpro/presentation/components/ui/custom_text.dart';
import 'package:flutter/material.dart';

class SilverListViewWidget extends StatelessWidget {
  const SilverListViewWidget({
    super.key,
    required this.screenHeight,
    required this.screenWidth,
    required this.text,
    required this.subText,
    required this.image,
    required this.subImage,
    required this.opressed,
  });

  final double screenHeight;
  final double screenWidth;
  final String text;
  final String subText;
  final String image;
  final String subImage;
  final VoidCallback opressed;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Center(
        child: Padding(
          padding: EdgeInsets.only(top: 14),
          child: Container(
            height: screenHeight * 0.32,
            width: screenWidth * 0.90,
            decoration: BoxDecoration(
              border: Border.all(width: 1, color: Colors.white),
              borderRadius: BorderRadius.circular(20),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                children: [
                  ImageFiltered(
                    imageFilter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                    child: Image.asset(
                      image,
                      fit: BoxFit.cover,
                      height: screenHeight * 0.32,
                      width: screenWidth * 0.90,
                    ),
                  ),
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              text,
                              style: TextStyle(
                                letterSpacing: 1,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: CustomText(
                              screenHeight: screenHeight,
                              onpressed: opressed,
                              text: 'View All',
                            ),
                          ),
                        ],
                      ),
                      Expanded(
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: 30,
                          itemBuilder: (context, index) {
                            return Container(
                              margin: EdgeInsets.symmetric(
                                  horizontal: 5, vertical: 18),
                              height: screenHeight * 0.12,
                              width: screenWidth * 0.40,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                    image: AssetImage(subImage),
                                    fit: BoxFit.cover,
                                    colorFilter: ColorFilter.mode(
                                        Colors.black.withOpacity(0.3),
                                        BlendMode.color)),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Container(
                                    width: double.infinity,
                                    height: screenHeight * 0.04,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.only(
                                          bottomRight: Radius.circular(10),
                                          bottomLeft: Radius.circular(10)),
                                      color: Colors.white,
                                    ),
                                    child: Center(
                                      child: Padding(
                                        padding:
                                            EdgeInsets.symmetric(horizontal: 4),
                                        child: Text(
                                          subText,
                                          style: TextStyle(
                                              color: Colors.black,
                                              overflow: TextOverflow.ellipsis),
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            );
                          },
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
    );
  }
}
