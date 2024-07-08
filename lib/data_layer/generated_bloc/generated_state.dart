part of 'generated_bloc.dart';

@immutable
sealed class GeneratedState {}

class GeneratedInitial extends GeneratedState {
  final int listViewCount;

  final List<File?> pickedImages;
  final File? pickImage;
  final String pickLocation;

  GeneratedInitial({
    required this.pickLocation,
    required this.pickImage,
    required this.listViewCount,
    required this.pickedImages,
  });
}

class ImagePickerInitial extends GeneratedState {}
