import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class VendorNmesWidget extends StatelessWidget {
  const VendorNmesWidget({
    super.key,
    required this.names,
    required this.nameEditingController,
    required this.screenWidth,
    required this.screenHeight,
  });

  final List<Map<String, String>> names;
  final TextEditingController nameEditingController;
  final double screenWidth;
  final double screenHeight;

  @override
  Widget build(BuildContext context) {
    return MasonryGridView.count(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: names.length,
      crossAxisCount: 2,
      crossAxisSpacing: 10.0,
      mainAxisSpacing: 10.0,
      itemBuilder: (context, index) {
        var data = names[index];
        return InkWell(
          onTap: () {
            nameEditingController.text = data['name']!;
          },
          child: Container(
            width: screenWidth * 0.4,
            height: screenHeight * 0.05,
            decoration: BoxDecoration(
              color: Colors.white38,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                data['name'] ?? 'NO name',
                style: TextStyle(
                  fontSize: screenHeight * 0.016,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
