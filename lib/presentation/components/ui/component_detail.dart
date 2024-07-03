// import 'dart:io';

// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:admineventpro/data_layer/generated/generated_bloc.dart';

// class ComponentDetailWidget extends StatelessWidget {
//   const ComponentDetailWidget({
//     super.key,
//     required this.screenHeight,
//     required this.screenWidth,
//   });

//   final double screenHeight;
//   final double screenWidth;

//   @override
//   Widget build(BuildContext context) {
//     return BlocBuilder<GeneratedBloc, GeneratedState>(
//       builder: (context, state) {
//         int? itemCount = 0;
//         List<File?>? images;
//         if (state is GeneratedInitial) {
//           itemCount = state.listViewCount;
//           images = state.pickedImages;
//         }

//         return Container(
//           height: screenHeight * 0.3,
//           child: ListView.builder(
//             scrollDirection: Axis.horizontal,
//             itemCount: itemCount,
//             itemBuilder: (context, index) {
//               return Container(
//                 width: screenWidth * 0.4,
//                 child: Padding(
//                   padding: EdgeInsets.all(8.0),
//                   child: Column(
//                     children: [
//                       GestureDetector(
//                         onTap: () {
//                           context
//                               .read<GeneratedBloc>()
//                               .add(PickImageEvent(index));
//                         },
//                         child: Stack(
//                           children: [
//                             Container(
//                               decoration: BoxDecoration(
//                                 borderRadius: BorderRadius.circular(10),
//                                 color: Colors.grey,
//                                 image: images != null && images[index] != null
//                                     ? DecorationImage(
//                                         image: FileImage(images[index]!),
//                                         fit: BoxFit.cover,
//                                       )
//                                     : null,
//                               ),
//                               child: images == null || images[index] == null
//                                   ? Center(
//                                       child: Icon(
//                                         Icons.collections_bookmark,
//                                         color: Colors.white,
//                                         size: 60,
//                                       ),
//                                     )
//                                   : null,
//                               width: screenWidth * 0.4,
//                               height: screenHeight * 0.16,
//                             ),
//                             if (images != null && images[index] != null)
//                               Positioned(
//                                 top: 0,
//                                 right: 0,
//                                 child: CircleAvatar(
//                                   backgroundColor: Colors.black,
//                                   child: IconButton(
//                                     icon: Icon(
//                                       Icons.close,
//                                       color: Colors.white,
//                                     ),
//                                     onPressed: () {
//                                       context
//                                           .read<GeneratedBloc>()
//                                           .add(RemoveImageEvent(index));
//                                     },
//                                   ),
//                                 ),
//                               ),
//                           ],
//                         ),
//                       ),
//                       SizedBox(height: 8),
//                       TextFormField(
//                         decoration: InputDecoration(
//                           border: OutlineInputBorder(
//                             borderSide: BorderSide(color: Colors.white),
//                             borderRadius: BorderRadius.circular(10),
//                           ),
//                           labelText: 'Displayed Name',
//                           labelStyle: TextStyle(
//                             color: Colors.white54,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               );
//             },
//           ),
//         );
//       },
//     );
//   }
// }
