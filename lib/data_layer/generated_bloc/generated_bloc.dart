import 'dart:async';
import 'dart:io';
import 'package:admineventpro/bussiness_layer/repos/location.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';

part 'generated_event.dart';
part 'generated_state.dart';

class GeneratedBloc extends Bloc<GeneratedEvent, GeneratedState> {
  int updatedItemCount = 0;

  GeneratedBloc()
      : super(GeneratedInitial(
          listViewCount: 1,
          pickedImages: [null],
          pickImage: null,
          pickLocation: '',
        )) {
    on<IncreamentEvent>(increamentEvent);
    on<DecrementEvent>(decrementEvent);
    on<PickImageEvent>(pickImage);
    on<RemoveImageEvent>(removeImage);
    on<PickImage>(pickImageDuplicate);
    on<FetchLocation>(fetchLocation);
    on<ClearImages>(clearImages);
    on<VendorSaveLoading>(saveLoading);
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
          pickedImages: (state as GeneratedInitial).pickedImages,
          pickLocation: (state as GeneratedInitial).pickLocation,
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

  Future<void> pickImage(
      PickImageEvent event, Emitter<GeneratedState> emit) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final updatedImages =
          List<File?>.from((state as GeneratedInitial).pickedImages);
      updatedImages[event.index] = File(pickedFile.path);

      emit(GeneratedInitial(
        listViewCount: (state as GeneratedInitial).listViewCount,
        pickImage: (state as GeneratedInitial).pickImage,
        pickLocation: (state as GeneratedInitial).pickLocation,
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
      pickImage: (state as GeneratedInitial).pickImage,
      pickLocation: (state as GeneratedInitial).pickLocation,
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
        pickImage: (state as GeneratedInitial).pickImage,
        pickLocation: (state as GeneratedInitial).pickLocation,
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
        pickImage: (state as GeneratedInitial).pickImage,
        pickLocation: (state as GeneratedInitial).pickLocation,
        pickedImages: updatedImages,
      ));
    }
  }

  FutureOr<void> fetchLocation(
      FetchLocation event, Emitter<GeneratedState> emit) async {
    try {
      bool serviceEnabled;
      LocationPermission permission;

      // Check if location services are enabled, prompt user to enable if not
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await Geolocator.openLocationSettings();
        if (!serviceEnabled) {
          print('Location services are disabled.');
          return;
        }
      }

      // Check location permissions
      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print('Location permissions are denied.');
        }
      }

      // Handle permanently denied location permissions
      if (permission == LocationPermission.deniedForever) {
        print('Location permissions are permanently denied.');
      }

      // Fetch current position
      final position = await Geolocator.getCurrentPosition();

      // Fetch location name using reverse geocoding
      String locationName =
          await getLocationName(position.latitude, position.longitude);

      // Emit LocationLoaded state with position and location name
      emit(GeneratedInitial(
        listViewCount: (state as GeneratedInitial).listViewCount,
        pickImage: (state as GeneratedInitial).pickImage,
        pickedImages: (state as GeneratedInitial).pickedImages,
        pickLocation: locationName,
      ));
    } catch (e) {
      print(e);
    }
  }

  FutureOr<void> clearImages(ClearImages event, Emitter<GeneratedState> emit) {
    emit(GeneratedInitial(
      listViewCount: 1,
      pickedImages: [null],
      pickLocation: '',
      pickImage: null,
    ));
  }

  FutureOr<void> saveLoading(
      VendorSaveLoading event, Emitter<GeneratedState> emit) {
    emit(saveVendorLoading());
  }
}
