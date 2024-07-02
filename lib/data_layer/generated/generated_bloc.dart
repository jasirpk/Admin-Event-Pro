import 'dart:async';
import 'dart:io';
import 'package:admineventpro/bussiness_layer/repos/upload_imgae_file.dart';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
        )) {
    on<IncreamentEvent>(increamentEvent);
    on<DecrementEvent>(decrementEvent);
    on<AddMoreTimeLineEvent>(addMoreTimeLine);
    on<ReduceTimeLineField>(reduceTimeLineField);
    on<PickImageEvent>(pickImage);
    on<RemoveImageEvent>(removeImage);
  }

  Future<void> pickImage(
      PickImageEvent event, Emitter<GeneratedState> emit) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final updatedImages =
          List<File?>.from((state as GeneratedInitial).pickedImages);
      updatedImages[event.index] = File(pickedFile.path);
      String? imageUrl = await uploadFile(updatedImages[event.index]!);
      await FirebaseFirestore.instance.collection('generatedVendors').add({
        'imageUrl': imageUrl,
        'timestamp': FieldValue.serverTimestamp(),
      });
      emit(GeneratedInitial(
        listViewCount: (state as GeneratedInitial).listViewCount,
        timeLineCount: (state as GeneratedInitial).timeLineCount,
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
        pickedImages: (state as GeneratedInitial).pickedImages,
      ));
    }
  }
}
