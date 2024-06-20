import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerList extends StatelessWidget {
  const ShimmerList({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return SizedBox(
      height: screenHeight, // Set height to cover the whole screen
      child: Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: 10, // Example item count
          itemBuilder: (context, index) {
            return Container(
              margin: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
              decoration: BoxDecoration(
                border: Border.all(
                    color: Colors.white.withOpacity(0.5), width: 0.5),
                borderRadius: BorderRadius.circular(10),
                color: Colors.white, // Add a base color for shimmer effect
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: screenWidth * 0.30,
                    height: screenHeight * 0.15,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.grey.shade400, // Shimmer base color
                    ),
                  ),
                  SizedBox(width: 8.0), // Space between shimmer blocks
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          height: 20.0,
                          color: Colors.grey.shade400, // Shimmer base color
                        ),
                        SizedBox(height: 8.0),
                        Container(
                          width: screenWidth * 0.5,
                          height: 20.0,
                          color: Colors.grey.shade400, // Shimmer base color
                        ),
                        SizedBox(height: 8.0),
                        Container(
                          width: screenWidth * 0.4,
                          height: 20.0,
                          color: Colors.grey.shade400, // Shimmer base color
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
