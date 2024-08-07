import 'dart:async';
import 'dart:io';
import 'package:admineventpro/data_layer/services/profile.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  int updatedItemCount = 0;
  int fieldUpdateCount = 0;
  ProfileBloc()
      : super(GeneratedInitial(
            pickedFields: [TextEditingController()],
            pickImage: null,
            listViewCount: 1,
            pickedImages: [null],
            fieldCount: 1)) {
    on<IncreamentEvent>(increamentEvent);
    on<DecrementEvent>(decrementEvent);
    on<PickImageEvent>(pickImage);
    on<RemoveImageEvent>(removeImage);
    on<PickImage>(pickImageDuplicate);
    on<ClearImages>(clearImages);
    on<AddMoreFields>(addMoreFields);
    on<Reducefield>(reduceField);
    on<SaveProfile>(saveProfile);
  }
  FutureOr<void> addMoreFields(
      AddMoreFields event, Emitter<ProfileState> emit) {
    if (state is GeneratedInitial) {
      fieldUpdateCount = (state as GeneratedInitial).fieldCount + 1;
      final updatedFields = List<TextEditingController>.from(
          (state as GeneratedInitial).pickedFields)
        ..add(TextEditingController());
      emit(GeneratedInitial(
        pickedFields: updatedFields,
        fieldCount: fieldUpdateCount,
        listViewCount: (state as GeneratedInitial).listViewCount,
        pickImage: (state as GeneratedInitial).pickImage,
        pickedImages: (state as GeneratedInitial).pickedImages,
      ));
    }
  }

  FutureOr<void> reduceField(Reducefield event, Emitter<ProfileState> emit) {
    if (state is GeneratedInitial &&
        (state as GeneratedInitial).fieldCount > 1) {
      fieldUpdateCount = (state as GeneratedInitial).fieldCount - 1;
      final updatedFields = List<TextEditingController>.from(
          (state as GeneratedInitial).pickedFields)
        ..removeLast();
      emit(GeneratedInitial(
        pickedFields: updatedFields,
        fieldCount: fieldUpdateCount,
        listViewCount: (state as GeneratedInitial).listViewCount,
        pickImage: (state as GeneratedInitial).pickImage,
        pickedImages: (state as GeneratedInitial).pickedImages,
      ));
    }
  }

  FutureOr<void> increamentEvent(
      IncreamentEvent event, Emitter<ProfileState> emit) {
    if (state is GeneratedInitial) {
      updatedItemCount = (state as GeneratedInitial).listViewCount + 1;
      final updatedImages =
          List<File?>.from((state as GeneratedInitial).pickedImages)..add(null);
      emit(GeneratedInitial(
        pickedFields: (state as GeneratedInitial).pickedFields,
        fieldCount: (state as GeneratedInitial).fieldCount,
        listViewCount: updatedItemCount,
        pickImage: (state as GeneratedInitial).pickImage,
        pickedImages: updatedImages,
      ));
    }
  }

  FutureOr<void> decrementEvent(
      DecrementEvent event, Emitter<ProfileState> emit) {
    if (state is GeneratedInitial &&
        (state as GeneratedInitial).listViewCount > 1) {
      updatedItemCount = (state as GeneratedInitial).listViewCount - 1;
      final updatedImages =
          List<File?>.from((state as GeneratedInitial).pickedImages)
            ..removeLast();
      emit(GeneratedInitial(
        pickedFields: (state as GeneratedInitial).pickedFields,
        fieldCount: (state as GeneratedInitial).fieldCount,
        listViewCount: updatedItemCount,
        pickImage: (state as GeneratedInitial).pickImage,
        pickedImages: updatedImages,
      ));
    }
  }

  FutureOr<void> removeImage(
      RemoveImageEvent event, Emitter<ProfileState> emit) {
    final updatedImages =
        List<File?>.from((state as GeneratedInitial).pickedImages);
    updatedImages[event.index] = null;
    emit(GeneratedInitial(
      pickedFields: (state as GeneratedInitial).pickedFields,
      fieldCount: (state as GeneratedInitial).fieldCount,
      listViewCount: (state as GeneratedInitial).listViewCount,
      pickImage: (state as GeneratedInitial).pickImage,
      pickedImages: updatedImages,
    ));
  }

  FutureOr<void> pickImage(
      PickImageEvent event, Emitter<ProfileState> emit) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final updatedImages =
          List<File?>.from((state as GeneratedInitial).pickedImages);
      updatedImages[event.index] = File(pickedFile.path);

      emit(GeneratedInitial(
        pickedFields: (state as GeneratedInitial).pickedFields,
        fieldCount: (state as GeneratedInitial).fieldCount,
        listViewCount: (state as GeneratedInitial).listViewCount,
        pickImage: (state as GeneratedInitial).pickImage,
        pickedImages: updatedImages,
      ));
    }
  }

  FutureOr<void> pickImageDuplicate(
      PickImage event, Emitter<ProfileState> emit) async {
    final picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        print('Image picked successfully: ${image.path}');
        final File updatedImage = File(image.path);
        emit(GeneratedInitial(
          pickedFields: (state as GeneratedInitial).pickedFields,
          fieldCount: (state as GeneratedInitial).fieldCount,
          listViewCount: (state as GeneratedInitial).listViewCount,
          pickedImages: (state as GeneratedInitial).pickedImages,
          pickImage: updatedImage,
        ));
        print('State updated with new image path: ${updatedImage.path}');
      } else {
        print('Image picking failed, no image selected.');
      }
    } catch (e) {
      print('Error occurred during image picking: $e');
    }
  }

  FutureOr<void> clearImages(ClearImages event, Emitter<ProfileState> emit) {
    emit(GeneratedInitial(
      pickedFields: [TextEditingController()],
      fieldCount: 1,
      listViewCount: 1,
      pickedImages: [null],
      pickImage: null,
    ));
  }

  FutureOr<void> saveProfile(
      SaveProfile event, Emitter<ProfileState> emit) async {
    emit(ProfileLoading());
    try {
      await UserProfile().addProfile(
          uid: event.uid,
          companyName: event.companyName,
          about: event.about,
          imagePath: event.imagePath,
          phoneNumber: event.phoneNumber,
          emailAddress: event.emailAddress,
          website: event.website,
          images: event.images,
          links: event.links,
          rating: event.rating,
          validate: true);
      emit(ProfileSuccess());
    } catch (e) {
      emit(ProfileError(error: e.toString()));
    }
  }
}
