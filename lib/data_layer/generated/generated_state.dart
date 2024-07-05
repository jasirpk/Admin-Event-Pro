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

class ComponentLoadedState extends GeneratedState {
  final int listviewItemCount;
  ComponentLoadedState(this.listviewItemCount);
}

class ComponentDecrementState extends GeneratedState {
  final int decrementCount;

  ComponentDecrementState(this.decrementCount);
}

class selectdImageState extends GeneratedState {
  final File? newImage;

  selectdImageState({required this.newImage});
}

class ImagePickerInitial extends GeneratedState {}

class LocationLoaded extends GeneratedState {
  final Position position;
  final String location;

  LocationLoaded(this.position, this.location);
}

class FormResetState extends GeneratedState {}
