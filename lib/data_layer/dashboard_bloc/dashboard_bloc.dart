import 'dart:async';

import 'package:admineventpro/common/assigns.dart';
import 'package:admineventpro/data_layer/services/cover_images.dart';
import 'package:bloc/bloc.dart';
part 'dashboard_event.dart';
part 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  DashboardBloc() : super(DashboardInitial()) {
    on<LoadCoverImages>(_onLoadCoverImages);
    on<SelectCoverImage>(_onSelectCoverImage);
    on<UploadCoverImage>(_onUploadCoverImage);
    on<TabChanged>((event, emit) {
      emit(TabState(event.newIndex));
    });
  }
  List<Map<String, dynamic>> images = [
    {'image': Assigns.image1},
    {'image': Assigns.image2},
    {'image': Assigns.image3},
    {'image': Assigns.image4},
    {'image': Assigns.image5},
    {'image': Assigns.image6},
  ];

  FutureOr<void> _onLoadCoverImages(
      LoadCoverImages event, Emitter<DashboardState> emit) {
    emit(CoverImageLoaded(images: images));
  }

  void _onSelectCoverImage(
      SelectCoverImage event, Emitter<DashboardState> emit) {
    final currentState = state;
    if (currentState is CoverImageLoaded) {
      emit(CoverImageLoaded(
          images: currentState.images, selectedImageIndex: event.index));
    }
  }

  Future<void> _onUploadCoverImage(
      UploadCoverImage event, Emitter<DashboardState> emit) async {
    final currentState = state;
    if (currentState is CoverImageLoaded &&
        currentState.selectedImageIndex != null) {
      try {
        emit(CoverImageLoading());
        final selectedImage =
            currentState.images[currentState.selectedImageIndex!]['image'];
        await CoverImageMethods().uploadImage(selectedImage, event.uid);
        emit(CoverImageUploaded());
        emit(CoverImageLoaded(
            images: currentState.images,
            selectedImageIndex: currentState.selectedImageIndex));
      } catch (e) {
        emit(CoverImageError('Failed to upload image'));
      }
    }
  }
}
