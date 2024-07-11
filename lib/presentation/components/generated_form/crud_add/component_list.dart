import 'dart:io';

import 'package:admineventpro/data_layer/generated_bloc/generated_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ComponentsWidget extends StatelessWidget {
  const ComponentsWidget({
    super.key,
    required this.screenHeight,
    required this.itemCount,
    required this.imageNameControllers,
    required this.screenWidth,
    required this.images,
  });

  final double screenHeight;
  final int? itemCount;
  final List<TextEditingController> imageNameControllers;
  final double screenWidth;
  final List<File?>? images;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: screenHeight * 0.3,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: itemCount,
        itemBuilder: (context, index) {
          if (imageNameControllers.length <= index) {
            imageNameControllers.add(TextEditingController());
          }

          return Container(
            width: screenWidth * 0.4,
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      context.read<GeneratedBloc>().add(PickImageEvent(index));
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
                          child: images == null || images![index] == null
                              ? Center(
                                  child: Icon(
                                    Icons.collections_bookmark,
                                    color: Colors.white,
                                    size: 60,
                                  ),
                                )
                              : Center(
                                  child: Icon(
                                    Icons.edit,
                                    color: Colors.white,
                                    size: 60,
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
                                      .read<GeneratedBloc>()
                                      .add(RemoveImageEvent(index));
                                },
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  SizedBox(height: 8),
                  TextFormField(
                    controller: imageNameControllers[index],
                    decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      labelText: 'Image Name',
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
  }
}
