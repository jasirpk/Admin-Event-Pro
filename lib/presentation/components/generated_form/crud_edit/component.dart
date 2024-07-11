import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:admineventpro/data_layer/generated_bloc/generated_bloc.dart';

class ComponentEditsWidget extends StatelessWidget {
  final double screenHeight;
  final int itemCount;
  final List<TextEditingController> imageNameControllers;
  final double screenWidth;
  final List<Map<String, dynamic>> imagesData;

  const ComponentEditsWidget({
    Key? key,
    required this.screenHeight,
    required this.itemCount,
    required this.imageNameControllers,
    required this.screenWidth,
    required this.imagesData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: screenHeight * 0.3,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: itemCount,
        itemBuilder: (context, index) {
          String? imageName = imagesData[index]['text'];
          String? imageUrl = imagesData[index]['imageUrl'];

          if (imageNameControllers.length <= index) {
            imageNameControllers.add(TextEditingController(text: imageName));
          } else {
            imageNameControllers[index].text = imageName ?? '';
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
                              image: DecorationImage(
                                  image: imageUrl!.startsWith('http')
                                      ? NetworkImage(imageUrl)
                                      : AssetImage(imageUrl) as ImageProvider,
                                  fit: BoxFit.cover)),
                          child: Center(
                            child: Icon(
                              Icons.edit,
                              color: Colors.white,
                              size: 60,
                            ),
                          ),
                          width: screenWidth * 0.4,
                          height: screenHeight * 0.16,
                        ),
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
                    onChanged: (value) {
                      imagesData[index]['text'] = value;
                    },
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
