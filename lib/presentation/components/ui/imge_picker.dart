// import 'dart:io';
// import 'package:admineventpro/data_layer/generated/generated_bloc.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';

// class ImagePickerWidget extends StatelessWidget {
//   final double screenHeight;

//   const ImagePickerWidget({
//     Key? key,
//     required this.screenHeight,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     String image = '';
//     return BlocBuilder<GeneratedBloc, GeneratedState>(
//       builder: (context, state) {
//         if (state is ImagePickerInitial) {
//           return Center(
//             child: CircularProgressIndicator(),
//           );
//         } else if (state is ImagePickerFailure) {
//           return Center(
//             child: Text('Failed to pick image'),
//           );
//         } else if (state is ImagePickerSuccess) {
//           image = state.imageDuplicate;
//         }
//         return GestureDetector(
//           onTap: () {
//             context.read<GeneratedBloc>().add(PickImage());
//           },
//           child: Container(
//             decoration: BoxDecoration(
//               color: Colors.grey,
//               borderRadius: BorderRadius.circular(10),
//               image: DecorationImage(
//                 image: FileImage(File(image)),
//                 fit: BoxFit.cover,
//               ),
//             ),
//             child: Center(
//               child: IconButton(
//                 icon: Icon(Icons.collections_bookmark,
//                     color: Colors.white, size: 40),
//                 onPressed: () {
//                   context.read<GeneratedBloc>().add(PickImage());
//                 },
//               ),
//             ),
//             height: screenHeight * 0.2,
//           ),
//         );
//       },
//     );
//   }
// }
