import 'package:admineventpro/common/style.dart';
import 'package:admineventpro/data_layer/generated/generated_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ComponentDetailWidget extends StatelessWidget {
  const ComponentDetailWidget({
    super.key,
    required this.screenHeight,
    required this.screenWidth,
  });

  final double screenHeight;
  final double screenWidth;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GeneratedBloc, GeneratedState>(
      builder: (context, state) {
        int itemCount = 0;
        if (state is GeneratedInitial) {
          itemCount = state.listViewCount;
        }

        return Container(
          height: screenHeight * 0.3,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: itemCount,
            itemBuilder: (context, index) {
              return Container(
                width: screenWidth * 0.4,
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.grey,
                        ),
                        child: Center(
                          child: Icon(
                            Icons.collections_bookmark,
                            color: Colors.white,
                            size: 60,
                          ),
                        ),
                        width: screenWidth * 0.4,
                        height: screenHeight * 0.16,
                      ),
                      sizedbox,
                      TextFormField(
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          labelText: 'Displayed Name',
                          labelStyle: TextStyle(
                            color: Colors.white54,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
