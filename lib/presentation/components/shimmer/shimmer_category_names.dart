import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerCategoryNames extends StatelessWidget {
  const ShimmerCategoryNames({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8),
      child: Shimmer.fromColors(
        baseColor: Colors.white24,
        highlightColor: Colors.white,
        child: Padding(
          padding: EdgeInsets.only(top: 12, bottom: 14),
          child: SizedBox(
            height: 35,
            child: ListView.builder(
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              itemCount: 6,
              itemBuilder: (context, index) {
                return Container(
                  margin: EdgeInsets.symmetric(horizontal: 5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    color: Colors.grey, // Add color to make it visible
                  ),
                  width: 100,
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
