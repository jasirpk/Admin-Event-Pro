part of 'generated_bloc.dart';

@immutable
sealed class GeneratedState {}

class GeneratedInitial extends GeneratedState {
  final int listViewCount;
  final int timeLineCount;
  final List<File?> pickedImages;
  final File? pickImage;

  GeneratedInitial({
    required this.pickImage,
    required this.listViewCount,
    required this.timeLineCount,
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

class TimeLineAddedState extends GeneratedState {
  final int TimeVeiwCount;

  TimeLineAddedState(this.TimeVeiwCount);
}

class TimeLineReduceState extends GeneratedState {
  final int TimeReduceCount;

  TimeLineReduceState(this.TimeReduceCount);
}

class selectdImageState extends GeneratedState {
  final File? newImage;

  selectdImageState({required this.newImage});
}

class ImagePickerLoading extends GeneratedState {}

class ImagePickerInitial extends GeneratedState {}

class ImagePickerSuccess extends GeneratedState {
  final String imageDuplicate;

  ImagePickerSuccess(this.imageDuplicate);
}

class ImagePickerFailure extends GeneratedState {}
