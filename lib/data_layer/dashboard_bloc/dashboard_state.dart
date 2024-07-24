part of 'dashboard_bloc.dart';

sealed class DashboardState {}

final class DashboardInitial extends DashboardState {}

class TabState extends DashboardState {
  final int index;

  TabState(this.index);
}

class CoverImageLoading extends DashboardState {}

class CoverImageLoaded extends DashboardState {
  final List<Map<String, dynamic>> images;
  final int? selectedImageIndex;

  CoverImageLoaded({required this.images, this.selectedImageIndex});
}

class CoverImageUploaded extends DashboardState {}

class CoverImageError extends DashboardState {
  final String message;

  CoverImageError(this.message);
}
