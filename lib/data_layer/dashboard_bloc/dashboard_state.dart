part of 'dashboard_bloc.dart';

sealed class DashboardState {}

final class DashboardInitial extends DashboardState {}

class TabState extends DashboardState {
  final int index;

  TabState(this.index);
}

class DashboardLoading extends DashboardState {
  // final String categoryId;
  // final String subCategoryId;

  // DashboardLoading({
  //   required this.categoryId,
  //   required this.subCategoryId,
  // });
}

class DashboardError extends DashboardState {
  final String errorMessage;

  DashboardError(this.errorMessage);
}

class DashboardFavoritesUpdated extends DashboardState {}

class DashboardFavoritesLoaded extends DashboardState {
  final List<DocumentSnapshot> favorites;

  DashboardFavoritesLoaded(this.favorites);
}
