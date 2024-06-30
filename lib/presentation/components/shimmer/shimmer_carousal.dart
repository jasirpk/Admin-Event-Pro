import 'package:admineventpro/presentation/components/shimmer/skelton.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerCarousal extends StatelessWidget {
  const ShimmerCarousal({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8),
      child: Shimmer.fromColors(
        baseColor: Colors.white24,
        highlightColor: Colors.white,
        child: ConstrainedBox(
          constraints: BoxConstraints.expand(height: 120),
          child: CarouselSlider.builder(
            itemCount: 4,
            itemBuilder: (context, index, _) {
              return Stack(
                children: [
                  Skelton(),
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: Skelton(
                      width: MediaQuery.of(context).size.width * 0.4,
                    ),
                  )
                ],
              );
            },
            options: CarouselOptions(
              aspectRatio: 16 / 9,
              reverse: false,
              viewportFraction: 0.48,
              autoPlayCurve: Curves.fastOutSlowIn,
              autoPlayInterval: Duration(seconds: 6),
              autoPlayAnimationDuration: Duration(seconds: 3),
              enlargeCenterPage: true,
              scrollDirection: Axis.horizontal,
            ),
          ),
        ),
      ),
    );
  }
}
