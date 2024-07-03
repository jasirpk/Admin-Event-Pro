import 'dart:async';
import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

part 'generated_event.dart';
part 'generated_state.dart';

class GeneratedBloc extends Bloc<GeneratedEvent, GeneratedState> {
  int updatedItemCount = 0;
  int timeLineIndex = 1;

  GeneratedBloc()
      : super(GeneratedInitial(
          listViewCount: 1,
          timeLineCount: 1,
          pickedImages: [null],
          pickImage: null,
        )) {
    on<IncreamentEvent>(increamentEvent);
    on<DecrementEvent>(decrementEvent);
    on<AddMoreTimeLineEvent>(addMoreTimeLine);
    on<ReduceTimeLineField>(reduceTimeLineField);
    on<PickImageEvent>(pickImage);
    on<RemoveImageEvent>(removeImage);
    on<PickImage>(pickImageDuplicate);
  }
  FutureOr<void> pickImageDuplicate(
      PickImage event, Emitter<GeneratedState> emit) async {
    final picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        print('Image picked successfully: ${image.path}');
        final File updatedImage = File(image.path);
        emit(GeneratedInitial(
          listViewCount: (state as GeneratedInitial).listViewCount,
          timeLineCount: (state as GeneratedInitial).timeLineCount,
          pickedImages: (state as GeneratedInitial).pickedImages,
          pickImage: updatedImage,
        ));
        print('State updated with new image path: ${updatedImage.path}');
      } else {
        emit(ImagePickerFailure());
        print('Image picking failed, no image selected.');
      }
    } catch (e) {
      emit(ImagePickerFailure());
      print('Error occurred during image picking: $e');
    }
  }

  Future<void> pickImage(
      PickImageEvent event, Emitter<GeneratedState> emit) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final updatedImages =
          List<File?>.from((state as GeneratedInitial).pickedImages);
      updatedImages[event.index] = File(pickedFile.path);
      // String? imageUrl = await uploadFile(updatedImages[event.index]!);
      // await FirebaseFirestore.instance.collection('generatedVendors').add({
      //   'imageUrl': imageUrl,
      //   'timestamp': FieldValue.serverTimestamp(),
      // });
      emit(GeneratedInitial(
        listViewCount: (state as GeneratedInitial).listViewCount,
        timeLineCount: (state as GeneratedInitial).timeLineCount,
        pickImage: (state as GeneratedInitial).pickImage,
        pickedImages: updatedImages,
      ));
    }
  }

  FutureOr<void> removeImage(
      RemoveImageEvent event, Emitter<GeneratedState> emit) {
    final updatedImages =
        List<File?>.from((state as GeneratedInitial).pickedImages);
    updatedImages[event.index] = null;
    emit(GeneratedInitial(
      listViewCount: (state as GeneratedInitial).listViewCount,
      timeLineCount: (state as GeneratedInitial).timeLineCount,
      pickImage: (state as GeneratedInitial).pickImage,
      pickedImages: updatedImages,
    ));
  }

  FutureOr<void> increamentEvent(
      IncreamentEvent event, Emitter<GeneratedState> emit) {
    if (state is GeneratedInitial) {
      updatedItemCount = (state as GeneratedInitial).listViewCount + 1;
      final updatedImages =
          List<File?>.from((state as GeneratedInitial).pickedImages)..add(null);
      emit(GeneratedInitial(
        listViewCount: updatedItemCount,
        timeLineCount: (state as GeneratedInitial).timeLineCount,
        pickImage: (state as GeneratedInitial).pickImage,
        pickedImages: updatedImages,
      ));
    }
  }

  FutureOr<void> decrementEvent(
      DecrementEvent event, Emitter<GeneratedState> emit) {
    if (state is GeneratedInitial &&
        (state as GeneratedInitial).listViewCount > 1) {
      updatedItemCount = (state as GeneratedInitial).listViewCount - 1;
      final updatedImages =
          List<File?>.from((state as GeneratedInitial).pickedImages)
            ..removeLast();
      emit(GeneratedInitial(
        listViewCount: updatedItemCount,
        timeLineCount: (state as GeneratedInitial).timeLineCount,
        pickImage: (state as GeneratedInitial).pickImage,
        pickedImages: updatedImages,
      ));
    }
  }

  FutureOr<void> addMoreTimeLine(
      AddMoreTimeLineEvent event, Emitter<GeneratedState> emit) {
    if (state is GeneratedInitial) {
      timeLineIndex = (state as GeneratedInitial).timeLineCount + 1;
      emit(GeneratedInitial(
        listViewCount: (state as GeneratedInitial).listViewCount,
        timeLineCount: timeLineIndex,
        pickImage: (state as GeneratedInitial).pickImage,
        pickedImages: (state as GeneratedInitial).pickedImages,
      ));
    }
  }

  FutureOr<void> reduceTimeLineField(
      ReduceTimeLineField event, Emitter<GeneratedState> emit) {
    if (state is GeneratedInitial &&
        (state as GeneratedInitial).timeLineCount > 1) {
      timeLineIndex = (state as GeneratedInitial).timeLineCount - 1;
      emit(GeneratedInitial(
        listViewCount: (state as GeneratedInitial).listViewCount,
        timeLineCount: timeLineIndex,
        pickImage: (state as GeneratedInitial).pickImage,
        pickedImages: (state as GeneratedInitial).pickedImages,
      ));
    }
  }
}
