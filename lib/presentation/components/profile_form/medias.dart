import 'dart:io';
import 'package:admineventpro/data_layer/profile_bloc/profile_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MediasWidget extends StatelessWidget {
  const MediasWidget({
    super.key,
    required this.screenHeight,
    required this.itemCount,
    required this.screenWidth,
    required this.images,
  });

  final double screenHeight;
  final int? itemCount;
  final double screenWidth;
  final List<File?>? images;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: screenHeight * 0.2,
      child: ListView.builder(
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        itemCount: itemCount,
        itemBuilder: (context, index) {
          return Container(
            width: screenWidth * 0.4,
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      context.read<ProfileBloc>().add(PickImageEvent(index));
                    },
                    child: Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.grey,
                            image: images != null && images![index] != null
                                ? DecorationImage(
                                    image: FileImage(images![index]!),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: Center(
                            child: Icon(
                              images == null || images![index] == null
                                  ? Icons.collections_bookmark
                                  : Icons.edit,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                          width: screenWidth * 0.4,
                          height: screenHeight * 0.16,
                        ),
                        if (images != null && images![index] != null)
                          Positioned(
                            top: 0,
                            right: 0,
                            child: CircleAvatar(
                              backgroundColor: Colors.black,
                              child: IconButton(
                                icon: Icon(
                                  Icons.close,
                                  color: Colors.white,
                                ),
                                onPressed: () {
                                  context
                                      .read<ProfileBloc>()
                                      .add(RemoveImageEvent(index));
                                },
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
