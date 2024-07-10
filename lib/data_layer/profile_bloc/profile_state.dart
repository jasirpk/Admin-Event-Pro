part of 'profile_bloc.dart';

@immutable
sealed class ProfileState {}

final class ProfileInitial extends ProfileState {}

class GeneratedInitial extends ProfileState {
  final int listViewCount;
  final int fieldCount;
  final List<TextEditingController> pickedFields;
  final List<File?> pickedImages;
  final File? pickImage;

  GeneratedInitial({
    required this.pickedFields,
    required this.fieldCount,
    required this.pickImage,
    required this.listViewCount,
    required this.pickedImages,
  });
}

class ImagePickerInitial extends ProfileState {}
